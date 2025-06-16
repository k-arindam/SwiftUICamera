//
//  SUICameraDataDelegate.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import UIKit
import AVFoundation

@objc
public protocol SUICameraDataDelegate: Sendable {
    var captureFrames: Bool { get }
    
    @objc optional func photoOutput(_ photo: AVCapturePhoto, error: (any Error)?) -> Void
    @objc optional func photoOutput(_ photo: UIImage?) -> Void
    
    @objc optional func finishedRecording(at url: URL, error: (any Error)?) -> Void
    
    @objc optional func frameOutput(ciImage: CIImage) -> Void
    @objc optional func frameOutput(original uiImage: UIImage?) -> Void
    @objc optional func frameOutput(rotated uiImage: UIImage?) -> Void
}
