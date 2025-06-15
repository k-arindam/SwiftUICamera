//
//  Frame+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

import AVFoundation
import UIKit

extension SUICameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        self.dataDelegate?.frameOutput?(ciImage: ciImage)
        self.dataDelegate?.frameOutput?(uiImage: uiimage(from: ciImage))
    }
}
