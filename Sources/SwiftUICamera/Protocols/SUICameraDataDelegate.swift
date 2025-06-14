//
//  SUICameraDataDelegate.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import UIKit
import AVFoundation

@objc
public protocol SUICameraDataDelegate: NSObjectProtocol {
    @objc optional func photoOutput(_ photo: AVCapturePhoto, error: (any Error)?) -> Void
    @objc optional func finishedRecording(at url: URL, error: (any Error)?) -> Void
    @objc optional func frameOutput(ciImage: CIImage) -> Void
    @objc optional func frameOutput(uiImage: UIImage?) -> Void
}
