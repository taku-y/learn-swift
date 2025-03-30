import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> VideoView {
        let view = VideoView()
        view.backgroundColor = .clear
        view.previewLayer.session = previewLayer.session
        view.previewLayer.videoGravity = .resizeAspectFill
        print("Initial preview layer frame: \(view.previewLayer.frame)")
        print("Initial view bounds: \(view.bounds)")
        return view
    }
    
    func updateUIView(_ uiView: VideoView, context: Context) {
        if let connection = uiView.previewLayer.connection {
            let currentDevice = UIDevice.current
            let orientation = currentDevice.orientation
            let previewLayerConnection = connection
            
            if previewLayerConnection.isVideoRotationAngleSupported(0) {
                switch orientation {
                case .portrait:
                    previewLayerConnection.videoRotationAngle = 90
                case .landscapeRight:
                    previewLayerConnection.videoRotationAngle = 180
                case .landscapeLeft:
                    previewLayerConnection.videoRotationAngle = 0
                case .portraitUpsideDown:
                    previewLayerConnection.videoRotationAngle = 270
                default:
                    previewLayerConnection.videoRotationAngle = 90
                }
            }
        }
    }
    
    static func dismantleUIView(_ uiView: VideoView, coordinator: ()) {
        print("Preview layer removed from superlayer")
    }
}

class VideoView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
} 