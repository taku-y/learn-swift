import SwiftUI
import AVFoundation
import UIKit
import CoreML

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    let onFrame: (CVPixelBuffer) -> Void
    
    func makeUIView(context: Context) -> VideoView {
        let view = VideoView()
        view.backgroundColor = .clear
        view.previewLayer.session = previewLayer.session
        view.previewLayer.videoGravity = .resizeAspectFill
        
        // フレーム処理用のセッション設定
        if let session = previewLayer.session {
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
        }
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let parent: CameraPreviewView
        
        init(_ parent: CameraPreviewView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            // CoreML用にピクセルバッファを変換
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
            
            // ここでCoreMLモデルの入力サイズに合わせてリサイズ
            let size = CGSize(width: 224, height: 224) // 例：一般的なCoreMLモデルの入力サイズ
            guard let resizedImage = cgImage.resized(to: size) else { return }
            
            // ピクセルバッファに変換
            if let resizedPixelBuffer = resizedImage.toPixelBuffer() {
                // CoreMLモデルへの入力用のコールバック
                DispatchQueue.main.async {
                    self.parent.onFrame(resizedPixelBuffer)
                }
            }
        }
    }
}

// 画像処理用の拡張
extension CGImage {
    func resized(to size: CGSize) -> CGImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let bytesPerRow = width * bytesPerPixel
        let bitsPerPixel = bytesPerPixel * 8
        
        var imageBytes: [UInt8] = Array(repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(
            data: &imageBytes,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        context.draw(self, in: CGRect(origin: .zero, size: size))
        return context.makeImage()
    }
    
    func toPixelBuffer() -> CVPixelBuffer? {
        let width = self.width
        let height = self.height
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            nil,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        context?.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return buffer
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