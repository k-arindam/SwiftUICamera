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
        
        let supportsAuto = device.isExposureModeSupported(.continuousAutoExposure) || device.isExposureModeSupported(.autoExpose)
        
        return SUICameraShutterSpeed.allCases.filter { shutterSpeed in
            if shutterSpeed == .auto { return supportsAuto }
            
            let actualSpeed = 1.0 / Float64(shutterSpeed.rawValue)
            return (minExposureDuration...maxExposureDuration).contains(actualSpeed)
        }
    }
    
    func change(shutterSpeed to: SUICameraShutterSpeed, completion: CapabilityChangeCallback = nil) -> Void {
        let precheckResult = precheck(selecting: to, from: supportedShutterSpeeds, current: currentShutterSpeed)
        
        switch precheckResult {
        case .redundant:
            completion?(.success(to))
            
        case .error(let error):
            completion?(.failure(error))
            
        case .proceed(let session, let device):
            mainqueue.async { self.currentShutterSpeed = to }
            
            switch to {
            case .auto:
                self.change(
                    exposure: .auto,
                    on: device,
                    with: session,
                    alias: to,
                    completion: completion
                )
            default:
                let exposure = SUICameraExposure.manual(duration: CMTimeMake(value: 1, timescale: Int32(to.rawValue)), iso: nil)
                self.change(
                    exposure: exposure,
                    on: device,
                    with: session,
                    alias: to,
                    completion: completion
                )
            }
        }
    }
}
