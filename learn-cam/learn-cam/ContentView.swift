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
        ZStack {
            if let previewLayer = cameraViewModel.previewLayer {
                CameraPreviewView(previewLayer: previewLayer)
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
            }
            
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

#Preview {
    ContentView()
}
