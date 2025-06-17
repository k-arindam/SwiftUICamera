//
//  PhotoCapture+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

@preconcurrency import AVFoundation
import UIKit

extension SUICameraViewModel: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let dataDelegate {
            dataDelegate.photoOutput?(photo, error: error)
            
            if error == nil, let data = photo.fileDataRepresentation(), !data.isEmpty {
                if let cgImageSource = CGImageSourceCreateWithData(data as CFData, nil),
                   let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil) {
                    let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: uiimageOrientation)
                    dataDelegate.photoOutput?(uiImage)
                }
            }
        }
        
        self.busy = false
    }
    
    public func capturePhoto() -> Void {
        self.switchMode(to: .photo, releaseLock: false) { mutated in
            guard let connection = self.photoOutput.connection(with: .video), connection.isActive else { return }
            
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.photoQualityPrioritization = .balanced
            
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}
