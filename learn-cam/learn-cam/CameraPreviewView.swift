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
            
            if previewLayerConnection.isVideoOrientationSupported {
                switch orientation {
                case .portrait:
                    previewLayerConnection.videoOrientation = .portrait
                case .landscapeRight:
                    previewLayerConnection.videoOrientation = .landscapeLeft
                case .landscapeLeft:
                    previewLayerConnection.videoOrientation = .landscapeRight
                case .portraitUpsideDown:
                    previewLayerConnection.videoOrientation = .portraitUpsideDown
                default:
                    previewLayerConnection.videoOrientation = .portrait
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