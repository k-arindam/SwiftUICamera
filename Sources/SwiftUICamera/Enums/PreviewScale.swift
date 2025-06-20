//
//  PreviewScale.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 18/06/25.
//

import AVFoundation

public enum PreviewScale: Codable, Sendable {
    case fit
    case fill
    
    var videoGravity: AVLayerVideoGravity {
        switch self {
        case .fit:
            return .resizeAspect
        case .fill:
            return .resizeAspectFill
        }
    }
}
