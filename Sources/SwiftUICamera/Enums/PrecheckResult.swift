//
//  PrecheckResult.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 21/06/25.
//

@preconcurrency import AVFoundation

enum PrecheckResult: Sendable {
    case redundant
    case error(SUICameraError)
    case proceed(AVCaptureSession, AVCaptureDevice)
}
