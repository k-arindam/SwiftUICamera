//
//  Zoom+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

@preconcurrency import AVFoundation

public extension SUICameraViewModel {
    internal func fetchSupportedZoom(of device: AVCaptureDevice) -> [SUICameraZoom] {
        let minZoom: CGFloat = 1.0
        let maxZoom: CGFloat = device.activeFormat.videoMaxZoomFactor
        
        return SUICameraZoom.allCases.filter { (minZoom...maxZoom).contains($0.rawValue) }
    }
    
    func change(zoom to: SUICameraZoom, completion: CapabilityChangeCallback = nil) -> Void {
        let precheckResult = precheck(selecting: to, from: supportedZoom, current: currentZoom)
        
        switch precheckResult {
        case .redundant:
            completion?(.success(to))
            
        case .error(let error):
            completion?(.failure(error))
            
        case .proceed(let session, let device):
            mainqueue.async { self.currentZoom = to }
            
            self.configure(device: device, session: session) {
                device.videoZoomFactor = to.rawValue
                completion?(.success(to))
            }
        }
    }
}
