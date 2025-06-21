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
    
    private func buildMenu<T: SUICameraCapability>(for elements: [T], with title: String, completion: @escaping (T) -> Void) -> some View {
        Menu {
            ForEach(elements) { element in
                Button("\(element.rawValue)".uppercased(), action: { completion(element) })
            }
        } label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.forward")
            }
        }
        .suicameraConfigCard()
    }
    
    var body: some View {
        VStack {
            SUICameraView(viewModel: viewModel)
            
            Picker("Camera Mode", selection: $viewModel.currentCameraMode) {
                ForEach(CameraMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.uppercased())
                }
            }
            .pickerStyle(.segmented)
            
            Toggle("Grid", isOn: $viewModel.gridEnabled)
                .suicameraConfigCard()
            
            if viewModel.currentCameraMode == .video {
                buildMenu(for: viewModel.supportedVideoQualities, with: "Video Quality") { viewModel.change(videoQuality: $0) }
            }
            
            buildMenu(for: viewModel.supportedShutterSpeeds, with: "Shutter Speed") { viewModel.change(shutterSpeed: $0) }
            buildMenu(for: viewModel.supportedISO, with: "ISO") { viewModel.change(iso: $0) }
            buildMenu(for: viewModel.supportedWhiteBalance, with: "White Balance") { viewModel.change(whiteBalance: $0) }
            
            HStack {
                switch viewModel.currentCameraMode {
                case .photo:
                    Button("Capture Photo", action: viewModel.capturePhoto)
                case .video:
                    Button("Start Recording", action: viewModel.startVideoRecording)
                    
                    Button("Stop Recording", action: viewModel.stopVideoRecording)
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

extension View {
    func suicameraConfigCard() -> some View {
        self.padding()
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
}
