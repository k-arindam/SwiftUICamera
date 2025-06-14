//
//  DeviceType.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import AVFoundation

internal enum DeviceType: String, Codable, CaseIterable {
    case video
    case audio
    
    var avMediaType: AVMediaType {
        switch self {
        case .video:
                .video
        case .audio:
                .audio
        }
    }
}
