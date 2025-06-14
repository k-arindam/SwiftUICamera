//
//  SUICameraAudioDevice.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import AVFoundation

public enum SUICameraAudioDevice: SUICameraCaptureDevice {
    case internalMicrophone
    
    var avCaptureDevice: AVCaptureDevice? {
        switch self {
        case .internalMicrophone:
                .default(for: .audio)
        }
    }
    
    var deviceType: DeviceType { .audio }
}
