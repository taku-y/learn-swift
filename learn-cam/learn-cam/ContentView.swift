//
//  ContentView.swift
//  learn-cam
//
//  Created by 吉岡琢 on 2025/03/30.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let previewLayer = cameraViewModel.previewLayer {
                    CameraPreviewView(previewLayer: previewLayer)
                        .frame(height: geometry.size.height * 0.8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding()
                } else {
                    Color.black
                        .frame(height: geometry.size.height * 0.8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding()
                }
                
                Spacer()
                
                Text("Camera app")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
            }
            .background(Color.black)
            .overlay {
                if !cameraViewModel.isAuthorized {
                    VStack {
                        Text("カメラへのアクセスが必要です")
                            .foregroundColor(.white)
                            .padding()
                        Button("設定を開く") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
