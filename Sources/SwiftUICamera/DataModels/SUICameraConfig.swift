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
        initialMode: CameraMode = .photo
    ) {
        self.videoDevice = videoDevice
        self.audioDevice = audioDevice
        self.initialMode = initialMode
    }
    
    let videoDevice: SUICameraVideoDevice?
    let audioDevice: SUICameraAudioDevice?
    
    let initialMode: CameraMode
    
    internal func copyWith(
        videoDevice: SUICameraVideoDevice? = nil,
        audioDevice: SUICameraAudioDevice? = nil,
        initialMode: CameraMode? = nil
    ) -> SUICameraConfig {
        .init(
            videoDevice: videoDevice ?? self.videoDevice,
            audioDevice: audioDevice ?? self.audioDevice,
            initialMode: initialMode ?? self.initialMode
        )
    }
}
