//
//  ShutterSpeed+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

@preconcurrency import AVFoundation

public extension SUICameraViewModel {
    internal func fetchSupportedShutterSpeeds(of device: AVCaptureDevice) -> [SUICameraShutterSpeed] {
        let minExposureDuration = CMTimeGetSeconds(device.activeFormat.minExposureDuration)
        let maxExposureDuration = CMTimeGetSeconds(device.activeFormat.maxExposureDuration)
        
        var shutterSpeeds = SUICameraShutterSpeed.allCases.filter { shutterSpeed in
            let actualSpeed = 1.0 / Float64(shutterSpeed.rawValue)
            return (minExposureDuration...maxExposureDuration).contains(actualSpeed)
        }
        
        if !shutterSpeeds.contains(.auto) {
            shutterSpeeds.append(.auto)
        }
        
        return shutterSpeeds
    }
    
    func change(shutterSpeed to: SUICameraShutterSpeed) -> Void {
        guard currentShutterSpeed != to else { return }
        mainqueue.async { self.currentShutterSpeed = to }
        
        switch to {
        case .auto:
            self.change(exposure: .auto)
        default:
            let exposure = SUICameraExposure.manual(duration: CMTimeMake(value: 1, timescale: Int32(to.rawValue)), iso: nil)
            self.change(exposure: exposure)
        }
    }
}
