//
//  Shared+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 18/06/25.
//

@preconcurrency import AVFoundation

internal extension SUICameraViewModel {
    func precheck<T>(current: T, selecting: T, from: [T]) -> PrecheckResult where T: SUICameraCapability {
        guard !busy else { return .error(.busy) }
        
        guard current != selecting else { return .redundant }
        
        guard from.contains(selecting) else { return .error(.unsupported) }
        
        guard let session, let device = videoDevice?.avCaptureDevice else { return .error(.unconfigured) }
        
        return .proceed(session, device)
    }
    
    func configure(
        device: AVCaptureDevice,
        session: AVCaptureSession,
        releaseLock: Bool = true,
        body: @Sendable @escaping () -> Void,
        completion: (@Sendable (_ error: SUICameraError?) -> Void)? = nil
    ) -> Void {
        @Sendable func bodyInternal() throws(SUICameraError) -> Void {
            do {
                try device.lockForConfiguration()
                body()
                device.unlockForConfiguration()
            } catch {
                throw .system(error.localizedDescription)
            }
        }
        
        self.configure(session: session, releaseLock: releaseLock, body: bodyInternal, completion: completion)
    }
    
    func configure(
        session: AVCaptureSession,
        releaseLock: Bool = true,
        body: @Sendable @escaping () throws(SUICameraError) -> Void,
        completion: (@Sendable (_ error: SUICameraError?) -> Void)? = nil
    ) -> Void {
        self.bgqueue.async {
            var cameraError: SUICameraError? = nil
            
            defer {
                completion?(cameraError)
                if releaseLock { self.busy = false }
            }
            
            do {
                self.busy = true
                session.beginConfiguration()
                try body()
                session.commitConfiguration()
            } catch let error as SUICameraError {
                cameraError = error
            } catch {
                cameraError = .unknown
            }
        }
    }
    
    func change<T>(
        exposure to: SUICameraExposure,
        on device: AVCaptureDevice,
        with session: AVCaptureSession,
        alias: T,
        completion: CapabilityChangeCallback
    ) -> Void where T: SUICameraCapability {
        self.configure(device: device, session: session) {
            switch to {
            case .auto:
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                    completion?(.success(alias))
                } else if device.isExposureModeSupported(.autoExpose) {
                    device.exposureMode = .autoExpose
                    completion?(.success(alias))
                } else {
                    completion?(.failure(.unsupported))
                }
            case .manual(let duration, let iso):
                guard device.isExposureModeSupported(.custom) else {
                    completion?(.failure(.unsupported))
                    return
                }
                
                let duration = duration ?? AVCaptureDevice.currentExposureDuration
                let iso = iso ?? AVCaptureDevice.currentISO
                
                device.setExposureModeCustom(duration: duration, iso: iso)
                completion?(.success(alias))
            }
        }
    }
}
