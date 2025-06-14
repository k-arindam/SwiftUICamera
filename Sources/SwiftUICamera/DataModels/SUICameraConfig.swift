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
        initialPreset: AVCaptureSession.Preset = .photo
    ) {
        self.videoDevice = videoDevice
        self.audioDevice = audioDevice
        self.initialPreset = initialPreset
    }
    
    let videoDevice: SUICameraVideoDevice?
    let audioDevice: SUICameraAudioDevice?
    
    let initialPreset: AVCaptureSession.Preset
    
    internal func copyWith(
        videoDevice: SUICameraVideoDevice? = nil,
        audioDevice: SUICameraAudioDevice? = nil
    ) -> SUICameraConfig {
        .init(
            videoDevice: videoDevice ?? self.videoDevice,
            audioDevice: audioDevice ?? self.audioDevice
        )
    }
}
