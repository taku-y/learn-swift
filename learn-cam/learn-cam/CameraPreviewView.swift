import SwiftUI
import AVFoundation
import UIKit

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> VideoView {
        let view = VideoView()
        view.backgroundColor = .clear
        view.previewLayer.session = previewLayer.session
        view.previewLayer.videoGravity = .resizeAspectFill
        
        // オーバーレイビューの追加
        let overlayView = CircleOverlayView()
        overlayView.backgroundColor = .clear
        view.addSubview(overlayView)
        overlayView.frame = view.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
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

class CircleOverlayView: UIView {
    private var circles: [(center: CGPoint, radius: CGFloat)] = []
    private var displayLink: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDisplayLink()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDisplayLink()
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateCircles))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateCircles() {
        // ランダムな円の生成
        circles = (0..<5).map { _ in
            let center = CGPoint(
                x: CGFloat.random(in: 0...bounds.width),
                y: CGFloat.random(in: 0...bounds.height)
            )
            let radius = CGFloat.random(in: 20...50)
            return (center: center, radius: radius)
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for circle in circles {
            context.setFillColor(UIColor.red.withAlphaComponent(0.3).cgColor)
            context.setStrokeColor(UIColor.red.cgColor)
            context.setLineWidth(2)
            
            context.addEllipse(in: CGRect(
                x: circle.center.x - circle.radius,
                y: circle.center.y - circle.radius,
                width: circle.radius * 2,
                height: circle.radius * 2
            ))
            
            context.drawPath(using: .fillStroke)
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
} 