import AVFoundation
import SwiftUI

class CameraViewModel: NSObject, ObservableObject {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isAuthorized = false
    
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
        // セッションの設定
        session.sessionPreset = .high
        
        // カメラデバイスの設定
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Failed to get camera device")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            
            // セッションの設定を開始
            session.beginConfiguration()
            
            // 既存の入力があれば削除
            session.inputs.forEach { session.removeInput($0) }
            
            // 入力の追加
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                print("Successfully added video input")
            } else {
                print("Failed to add video input")
                session.commitConfiguration()
                return
            }
            
            session.commitConfiguration()
            
            // プレビューレイヤーの設定
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer = previewLayer
            
            // セッションの開始
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
                print("Camera session started")
            }
        } catch {
            print("Failed to create video input: \(error.localizedDescription)")
        }
    }
    
    deinit {
        session.stopRunning()
    }
} 