//
//  ContentView.swift
//  learn-swift-basic
//
//  Created by taku-y on 2025/03/29.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var feature1: Double = 0.0
    @State private var feature2: Double = 0.0
    @State private var prediction: Int = 0
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("CoreML 分類サンプル")
                .font(.title)
                .foregroundColor(.blue)
            
            TextField("特徴量1", value: $feature1, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            TextField("特徴量2", value: $feature2, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            Button("予測") {
                predict()
            }
            .buttonStyle(.borderedProminent)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Text("予測結果: \(prediction)")
                .font(.headline)
                .padding()
        }
        .padding()
    }
    
    private func predict() {
        do {
            let config = MLModelConfiguration()
            let model = try SimpleClassifier(configuration: config)
            
            // Create input array with the features
            let inputArray = try MLMultiArray(shape: [1, 2], dataType: .double)
            inputArray[0] = feature1 as NSNumber
            inputArray[1] = feature2 as NSNumber
            
            let input = SimpleClassifierInput(input: inputArray)
            
            let output = try model.prediction(input: input)
            prediction = Int(truncatingIfNeeded: output.classLabel)
            errorMessage = nil
        } catch {
            errorMessage = "予測エラー: \(error.localizedDescription)"
            print("予測エラー: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
