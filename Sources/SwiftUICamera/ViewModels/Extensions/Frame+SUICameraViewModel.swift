//
//  Frame+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

import AVFoundation
@preconcurrency import CoreImage

extension SUICameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let dataDelegate,
              dataDelegate.captureFrames,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        dataDelegate.frameOutput?(ciImage: ciImage)
        
        self.bgqueue.async {
            if let original = self.uiimage(from: ciImage) {
                dataDelegate.frameOutput?(original: original)
            }
            
            if let rotated = self.uiimage(from: ciImage, orientation: self.uiimageOrientation) {
                dataDelegate.frameOutput?(rotated: rotated)
            }
        }
        
//        let originalRequest = CIImageRenderThread.RenderRequest(image: ciImage) { uiImage in
//            dataDelegate.frameOutput?(original: uiImage)
//        }
//        self.ciImageRenderThread.output(with: originalRequest)
//        
//        let rotatedRequest = CIImageRenderThread.RenderRequest(image: ciImage, orientation: uiimageOrientation) { uiImage in
//            dataDelegate.frameOutput?(rotated: uiImage)
//        }
//        self.ciImageRenderThread.output(with: rotatedRequest)
    }
}
