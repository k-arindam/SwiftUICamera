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
        audioDevice: .internalMicrophone,
        initialMode: .photo
    ))
    
    var body: some View {
        VStack {
            SUICameraView(viewModel: viewModel)
            
            Picker("Camera Mode", selection: $viewModel.currentCameraMode) {
                ForEach(CameraMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.uppercased())
                }
            }
            .pickerStyle(.segmented)
            
            HStack {
                switch viewModel.currentCameraMode {
                case .photo:
                    Button("Capture Photo", action: viewModel.capturePhoto)
                case .video:
                    Button("Start Video Recording", action: viewModel.startVideoRecording)
                    
                    Button("Stop Video Recording", action: viewModel.stopVideoRecording)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .animation(.easeInOut, value: viewModel.currentCameraMode)
        .task { viewModel.dataDelegate = DataHandler() }
    }
}

final class DataHandler: SUICameraDataDelegate {
    let captureFrames: Bool = false
    
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
    
    func frameOutput(rotated uiImage: UIImage?) {
        guard let _ = uiImage else { return }
    }
}

#Preview {
    ContentView()
}
