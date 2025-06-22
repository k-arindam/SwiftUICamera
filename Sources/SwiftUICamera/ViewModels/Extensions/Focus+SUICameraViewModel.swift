//
//  Focus+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

@preconcurrency import AVFoundation

public extension SUICameraViewModel {
    internal func fetchSupportedFocus(of device: AVCaptureDevice) -> [SUICameraFocus] {
        let minFocus: Float = 0.0
        let maxFocus: Float = 1.0
        
        let supportsAuto = device.isFocusModeSupported(.continuousAutoFocus) || device.isFocusModeSupported(.autoFocus)
        
        return SUICameraFocus.allCases.filter { focus in
            if focus == .auto { return supportsAuto }
            return (minFocus...maxFocus).contains(focus.rawValue)
        }
    }
    
    func change(focus to: SUICameraFocus, completion: CapabilityChangeCallback = nil) -> Void {
        let precheckResult = precheck(selecting: to, from: supportedFocus, current: currentFocus)
        
        switch precheckResult {
        case .redundant:
            completion?(.success(to))
            
        case .error(let error):
            completion?(.failure(error))
            
        case .proceed(let session, let device):
            mainqueue.async { self.currentFocus = to }
            
            self.configure(device: device, session: session) {
                switch to {
                case .auto:
                    if device.isFocusModeSupported(.continuousAutoFocus) {
                        device.focusMode = .continuousAutoFocus
                        completion?(.success(to))
                    } else if device.isFocusModeSupported(.autoFocus) {
                        device.focusMode = .autoFocus
                        completion?(.success(to))
                    } else {
                        completion?(.failure(.unsupported))
                    }
                    
                default:
                    guard device.isFocusModeSupported(.locked) else {
                        completion?(.failure(.unsupported))
                        return
                    }
                    
                    device.setFocusModeLocked(lensPosition: to.rawValue)
                    completion?(.success(to))
                }
            }
        }
    }
}
