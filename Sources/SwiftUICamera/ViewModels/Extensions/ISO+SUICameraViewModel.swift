//
//  ISO+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

import AVFoundation

public extension SUICameraViewModel {
    internal func fetchSupportedISO(of device: AVCaptureDevice) -> [SUICameraISO] {
        let minISO = Int(device.activeFormat.minISO)
        let maxISO = Int(device.activeFormat.maxISO)
        
        guard minISO < maxISO else { return [] }
        return SUICameraISO.allCases.filter { (minISO...maxISO).contains($0.rawValue) }
    }
}
