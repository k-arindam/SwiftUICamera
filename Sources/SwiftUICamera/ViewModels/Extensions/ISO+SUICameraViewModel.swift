//
//  ISO+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

@preconcurrency import AVFoundation

public extension SUICameraViewModel {
    internal func fetchSupportedISO(of device: AVCaptureDevice) -> [SUICameraISO] {
        let minISO = Int(device.activeFormat.minISO)
        let maxISO = Int(device.activeFormat.maxISO)
        
        guard minISO < maxISO else { return [] }
        
        let supportsAuto = device.isExposureModeSupported(.continuousAutoExposure) || device.isExposureModeSupported(.autoExpose)
        
        return SUICameraISO.allCases.filter { iso in
            if iso == .auto { return supportsAuto }
            return (minISO...maxISO).contains(iso.rawValue)
        }
    }
    
    func change(iso to: SUICameraISO, completion: CapabilityChangeCallback = nil) -> Void {
        let precheckResult = precheck(selecting: to, from: supportedISO, current: currentISO)
        
        switch precheckResult {
        case .redundant:
            completion?(.success(to))
            
        case .error(let error):
            completion?(.failure(error))
            
        case .proceed(let session, let device):
            mainqueue.async { self.currentISO = to }
            
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
                let exposure = SUICameraExposure.manual(duration: nil, iso: Float(to.rawValue))
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
