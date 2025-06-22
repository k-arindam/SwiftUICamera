//
//  WB+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

@preconcurrency import AVFoundation

public extension SUICameraViewModel {
    internal func fetchSupportedWB(of device: AVCaptureDevice) -> [SUICameraWB] {
        func wbGainAvailable(for value: SUICameraWB) -> Bool {
            let minWB = 2300
            let maxWB = 7500
            
            guard (minWB...maxWB).contains(value.rawValue) else { return false }
            
            let temperatureAndTintValues = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: Float(value.rawValue), tint: value.tint)
            
            let wbGains = device.deviceWhiteBalanceGains(for: temperatureAndTintValues)
            let maxGain = device.maxWhiteBalanceGain
            
            return (wbGains.redGain <= maxGain) && (wbGains.greenGain <= maxGain) && (wbGains.blueGain <= maxGain)
        }
        
        let supportsAuto = device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) || device.isWhiteBalanceModeSupported(.autoWhiteBalance)
        
        return SUICameraWB.allCases.filter { wb in
            if wb == .auto { return supportsAuto }
            return wbGainAvailable(for: wb)
        }
    }
    
    func change(whiteBalance to: SUICameraWB, completion: CapabilityChangeCallback = nil) -> Void {
        let precheckResult = precheck(selecting: to, from: supportedWhiteBalance, current: currentWhiteBalance)
        
        switch precheckResult {
        case .redundant:
            completion?(.success(to))
            
        case .error(let error):
            completion?(.failure(error))
            
        case .proceed(let session, let device):
            mainqueue.async { self.currentWhiteBalance = to }
            
            self.configure(device: device, session: session) {
                switch to {
                case .auto:
                    if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                        device.whiteBalanceMode = .continuousAutoWhiteBalance
                        completion?(.success(to))
                    } else if device.isWhiteBalanceModeSupported(.autoWhiteBalance) {
                        device.whiteBalanceMode = .autoWhiteBalance
                        completion?(.success(to))
                    } else {
                        completion?(.failure(.unsupported))
                    }
                default:
                    guard device.isWhiteBalanceModeSupported(.locked) else {
                        completion?(.failure(.unsupported))
                        return
                    }
                    
                    device.whiteBalanceMode = .locked
                    
                    let chromaticValues = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: Float(to.rawValue), tint: to.tint)
                    let gains = device.deviceWhiteBalanceGains(for: chromaticValues)
                    
                    device.setWhiteBalanceModeLocked(with: gains)
                    completion?(.success(to))
                }
            }
        }
    }
}
