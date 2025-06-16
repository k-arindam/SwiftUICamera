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
    @StateObject var viewModel = SUICameraViewModel(with: .init(
        videoDevice: .backWideAngleCamera,
        audioDevice: .internalMicrophone
    ))
    
    var body: some View {
        VStack {
            SUICameraView(viewModel: viewModel)
            
            HStack {
                Button("Capture Photo", action: viewModel.capturePhoto)
                    .buttonStyle(.borderedProminent)
                
                Button("Start Video Recording", action: viewModel.startVideoRecording)
                    .buttonStyle(.borderedProminent)
                
                Button("Stop Video Recording", action: viewModel.stopVideoRecording)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .task { viewModel.dataDelegate = DataHandler() }
    }
}

final class DataHandler: SUICameraDataDelegate {
    let captureFrames: Bool = true
    
    func photoOutput(_ photo: UIImage?) {
        guard let output = photo else { return }
        UIImageWriteToSavedPhotosAlbum(output, nil, nil, nil)
    }
    
    func finishedRecording(at url: URL, error: (any Error)?) {
        guard error == nil else { return }
        
        let path = url.path()
        let canSave = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)
        if canSave {
            UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil)
        }
    }
}

#Preview {
    ContentView()
}
