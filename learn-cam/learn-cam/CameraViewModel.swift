import AVFoundation
import SwiftUI
import CoreML

class CameraViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isAuthorized = false
    @Published var predictionResult: String = "No prediction yet"
    
    private let session = AVCaptureSession()
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }
    
    private func setupCamera() {
        // プレビューレイヤーの設定（即時表示）
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer = previewLayer
        
        // カメラの初期化を非同期で実行
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // セッションの設定
            self.session.sessionPreset = .medium
            
            // カメラデバイスの設定
            guard let videoDevice = AVCaptureDevice.default(for: .video) else {
                print("Failed to get camera device")
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                
                // セッションの設定を開始
                self.session.beginConfiguration()
                
                // 既存の入力があれば削除
                self.session.inputs.forEach { self.session.removeInput($0) }
                
                // 入力の追加
                print("Can video input added: \(self.session.canAddInput(videoInput))")
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                    print("Successfully added video input")
                } else {
                    print("Failed to add video input")
                    self.session.commitConfiguration()
                    return
                }
                
                // ビデオ出力の設定
                let videoOutput = AVCaptureVideoDataOutput()
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                
                print("Can video output added: \(self.session.canAddOutput(videoOutput))")
                if self.session.canAddOutput(videoOutput) {
                    self.session.addOutput(videoOutput)
                    print("Successfully added video output")
                } else {
                    print("Failed to add video output")
                    self.session.commitConfiguration()
                    return
                }
                
                self.session.commitConfiguration()
                
                // セッションの開始
                self.session.startRunning()
                print("Camera session started")
                
                // 3秒後にセッションの状態を確認
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    print("Session running after 3 seconds: \(self.session.isRunning)")
                }
            } catch {
                print("Failed to create video input: \(error.localizedDescription)")
            }
        }
    }
    
    deinit {
        session.stopRunning()
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // ここでビデオフレームの処理を行う
        // 例：フレームの保存、処理、表示など
    }
    
    // MARK: - CoreML Processing
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        // ここにCoreMLモデルの処理を実装
        // 例：
        /*
        do {
            let config = MLModelConfiguration()
            let model = try YourModel(configuration: config)
            let prediction = try model.prediction(input: YourModelInput(image: pixelBuffer))
            DispatchQueue.main.async {
                self.predictionResult = prediction.output
            }
        } catch {
            print("CoreML prediction error: \(error)")
        }
        */
        
        // モックの実装
        DispatchQueue.main.async {
            self.predictionResult = "Processing frame at \(Date())"
        }
    }
} 