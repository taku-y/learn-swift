//
//  ContentView.swift
//  learn-cam
//
//  Created by 吉岡琢 on 2025/03/30.
//

import SwiftUI

extension View {
    func Print(_ item: Any) -> some View {
        print(item)
        return self
    }
}

struct ContentView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // カメラプレビュー
                if let previewLayer = viewModel.previewLayer {
                    CameraPreviewView(previewLayer: previewLayer) { pixelBuffer in
                        Task {
                            await viewModel.processFrame(pixelBuffer)
                        }
                    }
                    .frame(height: geometry.size.height * 0.5)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: geometry.size.height * 0.5)
                }
                
                // 深度マップ
                if let depthMap = viewModel.depthMap {
                    GeometryReader { depthGeometry in
                        Image(uiImage: depthMap)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .rotationEffect(.degrees(90)) // 90度回転
                            .frame(width: depthGeometry.size.width, height: depthGeometry.size.height)
                            .clipped()
                    }
                    .frame(height: geometry.size.height * 0.5)
                } else {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: geometry.size.height * 0.5)
                }
            }
            .frame(maxWidth: .infinity)
            
            // カメラアクセス許可オーバーレイ
            if !viewModel.isAuthorized {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Text("カメラへのアクセスを許可してください")
                            .foregroundColor(.white)
                    )
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
