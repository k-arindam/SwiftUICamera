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
    @StateObject var vm = SUICameraViewModel(with: .init(
        videoDevice: .backWideAngleCamera,
        audioDevice: .internalMicrophone,
        initialMode: .photo,
        initiallyGridEnabled: true
    ))
    
    private func buildMenu<T: SUICameraCapability>(for elements: [T], with title: String, current: T, completion: @escaping (T) -> Void) -> some View {
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
    }
    
    var body: some View {
        VStack {
            SUICameraView(viewModel: vm)
                .frame(height: UIScreen.main.bounds.height * 0.5)
            
            List {
                Section("Basic Operations") {
                    Picker("Camera Mode", selection: $vm.currentCameraMode) {
                        ForEach(CameraMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.uppercased())
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Grid", isOn: $vm.gridEnabled)
                }
                
                Section("Advanced Operations") {
                    if vm.currentCameraMode == .video {
                        buildMenu(for: vm.supportedVideoQualities, with: "Video Quality", current: vm.currentVideoQuality) { vm.change(videoQuality: $0) }
                    }
                    
                    buildMenu(for: vm.supportedFocus, with: "Focus", current: vm.currentFocus) { vm.change(focus: $0) }
                    buildMenu(for: vm.supportedZoom, with: "Zoom", current: vm.currentZoom) { vm.change(zoom: $0) }
                    buildMenu(for: vm.supportedShutterSpeeds, with: "Shutter Speed", current: vm.currentShutterSpeed) { vm.change(shutterSpeed: $0) }
                    buildMenu(for: vm.supportedISO, with: "ISO", current: vm.currentISO) { vm.change(iso: $0) }
                    buildMenu(for: vm.supportedWhiteBalance, with: "White Balance", current: vm.currentWhiteBalance) { vm.change(whiteBalance: $0) }
                }
                
                Section("Capture & Save") {
                    HStack {
                        switch vm.currentCameraMode {
                        case .photo:
                            Button("Capture Photo", action: vm.capturePhoto)
                        case .video:
                            Button("Start Recording", action: vm.startVideoRecording)
                            
                            Button("Stop Recording", action: vm.stopVideoRecording)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .animation(.easeInOut, value: vm.currentCameraMode)
        .task { vm.dataDelegate = DataHandler() }
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
