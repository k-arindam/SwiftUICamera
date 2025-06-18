//
//  VQDescription.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 18/06/25.
//

@preconcurrency import AVFoundation

internal struct VQDescription: Sendable {
    let format: AVCaptureDevice.Format
    let frameRate: Int
}
