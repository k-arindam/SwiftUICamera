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
        
        var wb = SUICameraWB.allCases.filter { wbGainAvailable(for: $0) }
        
        if !wb.contains(.auto) {
            wb.append(.auto)
        }
        
        return wb
    }
    
    func change(whiteBalance to: SUICameraWB) -> Void {
        guard !busy,
              currentWhiteBalance != to,
              supportedWhiteBalance.contains(to),
              let session,
              let device = videoDevice?.avCaptureDevice
        else { return }
        
        mainqueue.async { self.currentWhiteBalance = to }
        
        self.configure(device: device, session: session) {
            if to == .auto {
                if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                    device.whiteBalanceMode = .continuousAutoWhiteBalance
                } else if device.isWhiteBalanceModeSupported(.autoWhiteBalance) {
                    device.whiteBalanceMode = .autoWhiteBalance
                }
                
                return
            }
            
            if device.isWhiteBalanceModeSupported(.locked) {
                device.whiteBalanceMode = .locked
                
                let chromaticValues = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: Float(to.rawValue), tint: to.tint)
                let gains = device.deviceWhiteBalanceGains(for: chromaticValues)
                
                device.setWhiteBalanceModeLocked(with: gains)
            }
        }
    }
}
