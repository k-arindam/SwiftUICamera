//
//  CameraMode.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 17/06/25.
//

import AVFoundation

public enum CameraMode: String, Codable, Sendable, CaseIterable {
    case photo
    case video
    
    var preset: AVCaptureSession.Preset {
        switch self {
            case .photo:
            return .photo
        case .video:
            return .high
        }
    }
}
