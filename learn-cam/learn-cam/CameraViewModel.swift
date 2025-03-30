import AVFoundation
import SwiftUI
import CoreML
import Vision
import UIKit

@MainActor
class CameraViewModel: NSObject, ObservableObject, @preconcurrency AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isAuthorized = false
    @Published var predictionResult: String = "No prediction yet"
    @Published var depthMap: UIImage?
    
    private var captureSession: AVCaptureSession?
    private var depthModel: MLModel?
    
    override init() {
        super.init()
        setupCamera()
        setupDepthModel()
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        captureSession = session
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("カメラが見つかりません")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer = previewLayer
            
            Task {
                await checkPermissions()
                if isAuthorized {
                    session.startRunning()
                }
            }
        } catch {
            print("カメラのセットアップに失敗しました: \(error)")
        }
    }
    
    private func setupDepthModel() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all
            
            print("Bundle path: \(Bundle.main.bundlePath)")
            print("All resources: \(Bundle.main.paths(forResourcesOfType: "mlmodelc", inDirectory: nil))")
            
            if let modelURL = Bundle.main.url(forResource: "DepthAnythingV2SmallF16P6", withExtension: "mlmodelc") {
                print("Model URL found: \(modelURL)")
                print("Model file exists: \(FileManager.default.fileExists(atPath: modelURL.path))")
                depthModel = try MLModel(contentsOf: modelURL, configuration: config)
                print("Model loaded successfully")
            } else {
                print("Error: Model file not found in bundle")
                print("Available resources: \(Bundle.main.paths(forResourcesOfType: nil, inDirectory: nil))")
            }
        } catch {
            print("Error loading model: \(error)")
        }
    }
    
    private func checkPermissions() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        default:
            isAuthorized = false
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        Task { @MainActor in
            await processFrame(pixelBuffer)
        }
    }
    
    // MARK: - CoreML Processing
    func processFrame(_ pixelBuffer: CVPixelBuffer) async {
        guard let model = depthModel else {
            print("Model not loaded")
            return
        }
        
        do {
            print("Processing frame...")
            // モデルの入力サイズに合わせてリサイズ
            let resizedBuffer = resizePixelBuffer(pixelBuffer, targetSize: CGSize(width: 518, height: 392))
            
            // モデルに入力
            let modelInput = try MLDictionaryFeatureProvider(dictionary: ["image": MLFeatureValue(pixelBuffer: resizedBuffer)])
            let modelOutput = try await model.prediction(from: modelInput)
            
            // 利用可能な出力フィーチャーを確認
            print("Available output features: \(modelOutput.featureNames)")
            
            // 深度マップを取得
            if let depthFeature = modelOutput.featureValue(for: "depth") {
                print("Depth feature type: \(type(of: depthFeature))")
                
                // 深度マップをUIImageに変換
                if let depthImage = convertDepthFeatureToImage(depthFeature) {
                    print("Depth image created successfully")
                    self.depthMap = depthImage
                } else {
                    print("Failed to convert depth feature to image")
                }
            } else {
                print("No depth feature in model output")
            }
        } catch {
            print("フレーム処理エラー: \(error)")
        }
    }
    
    private func resizePixelBuffer(_ buffer: CVPixelBuffer, targetSize: CGSize) -> CVPixelBuffer {
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let transform = CGAffineTransform(scaleX: targetSize.width / ciImage.extent.width,
                                        y: targetSize.height / ciImage.extent.height)
        let resizedImage = ciImage.transformed(by: transform)
        
        var resizedBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault,
                          Int(targetSize.width),
                          Int(targetSize.height),
                          kCVPixelFormatType_32BGRA,
                          nil,
                          &resizedBuffer)
        
        if let resizedBuffer = resizedBuffer {
            CIContext().render(resizedImage, to: resizedBuffer)
        }
        
        return resizedBuffer ?? buffer
    }
    
    private func convertDepthFeatureToImage(_ feature: MLFeatureValue) -> UIImage? {
        guard let pixelBuffer = feature.imageBufferValue else {
            print("Failed to get image buffer from feature")
            return nil
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("Failed to create CGImage")
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
} 
