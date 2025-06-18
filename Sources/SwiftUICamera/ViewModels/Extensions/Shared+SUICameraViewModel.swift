//
//  Shared+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 18/06/25.
//

@preconcurrency import AVFoundation

internal extension SUICameraViewModel {
    func change(exposure to: SUICameraExposure) -> Void {
        guard !busy,
              let session,
              let device = videoDevice?.avCaptureDevice
        else { return }
        
        self.configure(device: device, session: session) {
            switch to {
            case .auto:
                device.exposureMode = .continuousAutoExposure
            case .manual(let duration, let iso):
                let duration = duration ?? AVCaptureDevice.currentExposureDuration
                let iso = iso ?? AVCaptureDevice.currentISO
                
                device.setExposureModeCustom(duration: duration, iso: iso)
            }
        }
    }
}
