//
//  AVCaptureSession+Extensions.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import AVFoundation

internal extension AVCaptureSession {
    func addInputIfPossible(_ input: AVCaptureInput) -> Bool {
        let isAddable = canAddInput(input)
        
        if isAddable {
            addInput(input)
        }
        
        return isAddable
    }
    
    func addOutputIfPossible(_ output: AVCaptureOutput) -> Bool {
        let isAddable = canAddOutput(output)
        
        if isAddable {
            addOutput(output)
        }
        
        return isAddable
    }
}
