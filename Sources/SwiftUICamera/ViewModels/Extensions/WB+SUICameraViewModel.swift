//
//  WB+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

import AVFoundation

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
        
        return SUICameraWB.allCases.filter { wbGainAvailable(for: $0) }
    }
}
