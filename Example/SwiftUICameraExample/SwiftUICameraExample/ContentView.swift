//
//  ContentView.swift
//  SwiftUICameraExample
//
//  Created by Arindam Karmakar on 13/06/25.
//

import SwiftUI
import SwiftUICamera
import AVFoundation

struct ContentView: View {
    @StateObject var data = DataDelegate()
    @StateObject var viewModel = SUICameraViewModel(with: .init(
        videoDevice: .backWideAngleCamera,
        audioDevice: .internalMicrophone
    ))
    
    var body: some View {
        VStack {
            SUICameraView(viewModel: viewModel)
            
            Image(uiImage: data.frame)
                .resizable()
                .scaledToFit()
            
            Button("Capture Photo", action: viewModel.capturePhoto)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .task { viewModel.dataDelegate = data }
    }
}

final class DataDelegate: ObservableObject, SUICameraDataDelegate {
    @Published var frame = UIImage()
    
    func photoOutput(_ photo: AVCapturePhoto, error: (any Error)?) {
        debugPrint("----->>> Photo Captured!")
    }
    
    func frameOutput(uiImage: UIImage?) {
        if let uiImage {
            DispatchQueue.main.async {
                self.frame = uiImage
            }
        }
    }
}

#Preview {
    ContentView()
}
