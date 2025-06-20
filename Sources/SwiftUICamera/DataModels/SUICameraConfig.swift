//
//  SUICameraConfig.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import AVFoundation

public struct SUICameraConfig {
    public init(
        videoDevice: SUICameraVideoDevice? = nil,
        audioDevice: SUICameraAudioDevice? = nil,
        initialMode: CameraMode = .photo,
        initiallyGridEnabled: Bool = true
    ) {
        self.videoDevice = videoDevice
        self.audioDevice = audioDevice
        self.initialMode = initialMode
        self.initiallyGridEnabled = initiallyGridEnabled
    }
    
    let videoDevice: SUICameraVideoDevice?
    let audioDevice: SUICameraAudioDevice?
    
    let initialMode: CameraMode
    let initiallyGridEnabled: Bool
    
    internal func copyWith(
        videoDevice: SUICameraVideoDevice? = nil,
        audioDevice: SUICameraAudioDevice? = nil,
        initialMode: CameraMode? = nil,
        initiallyGridEnabled: Bool? = nil
    ) -> SUICameraConfig {
        .init(
            videoDevice: videoDevice ?? self.videoDevice,
            audioDevice: audioDevice ?? self.audioDevice,
            initialMode: initialMode ?? self.initialMode,
            initiallyGridEnabled: initiallyGridEnabled ?? self.initiallyGridEnabled
        )
    }
}
