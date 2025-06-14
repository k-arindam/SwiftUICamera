//
//  SUICameraVideoDevice.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import AVFoundation

public enum SUICameraVideoDevice: SUICameraCaptureDevice {
    case frontWideAngleCamera
    
    case backWideAngleCamera
    case backUltraWideCamera
    case backTelephotoCamera
    
    var avCaptureDevice: AVCaptureDevice? {
        switch self {
        case .frontWideAngleCamera:
                .default(.builtInWideAngleCamera, for: .video, position: .front)
        case .backWideAngleCamera:
                .default(.builtInWideAngleCamera, for: .video, position: .back)
        case .backUltraWideCamera:
                .default(.builtInUltraWideCamera, for: .video, position: .back)
        case .backTelephotoCamera:
                .default(.builtInTelephotoCamera, for: .video, position: .back)
        }
    }
    
    var deviceType: DeviceType { .video }
}
