//
//  PhotoCapture+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

@preconcurrency import AVFoundation

extension SUICameraViewModel: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        self.dataDelegate?.photoOutput?(photo, error: error)
        self.busy = false
    }
    
    public func capturePhoto() -> Void {
        guard let session = session else { return }
        
        configure(session: session, releaseLock: false) {
            session.sessionPreset = .photo
        } completion: {
            guard let connection = self.photoOutput.connection(with: .video), connection.isActive else { return }
            
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.photoQualityPrioritization = .balanced
            
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}
