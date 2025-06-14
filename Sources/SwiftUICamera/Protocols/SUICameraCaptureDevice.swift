//
//  SUICameraCaptureDevice.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import AVFoundation

protocol SUICameraCaptureDevice: Codable, CaseIterable {
    var avCaptureDevice: AVCaptureDevice? { get }
    var deviceType: DeviceType { get }
}
