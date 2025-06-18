//
//  SUICameraVideoQuality.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import AVFoundation

public enum SUICameraVideoQuality: String, SUICameraCapability {
    public typealias T = String
    public var id: String { rawValue }
    
    case vq4K24FPS = "4K 24FPS"
    case vq4K30FPS = "4K 30FPS"
    case vq4K60FPS = "4K 60FPS"
    
    case vq2K30FPS = "2K 30FPS"
    case vq2K60FPS = "2K 60FPS"
    
    case vqFHD30FPS = "FHD 30FPS"
    case vqFHD60FPS = "FHD 60FPS"
    
    case vqFHD240FPS = "FHD 240FPS"
    
    case vqHD30FPS = "HD 30FPS"
    case vqHD60FPS = "HD 60FPS"
    
    internal static func fromRawVideoQuality(_ dims: CMVideoDimensions, fps: Int) -> SUICameraVideoQuality? {
        switch (dims.width, dims.height, fps) {
        case (3840, 2160, 24):
            return .vq4K24FPS
            
        case (3840, 2160, 30):
            return .vq4K30FPS
            
        case (3840, 2160, 60):
            return .vq4K60FPS
            
        case (1920, 1080, 30):
            return .vqFHD30FPS
            
        case (1920, 1080, 60):
            return .vqFHD60FPS
            
        case (1920, 1080, 240):
            return .vqFHD240FPS
            
        case (1280, 720, 30):
            return .vqHD30FPS
            
        case (1280, 720, 60):
            return .vqHD60FPS
            
        default:
            return nil
        }
    }
}
