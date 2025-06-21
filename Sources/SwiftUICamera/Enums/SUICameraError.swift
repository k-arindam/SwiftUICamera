//
//  SUICameraError.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import Foundation

public enum SUICameraError: Error, Codable, Sendable {
    case busy
    case deviceUnavailable
    case unableToAttachDevice
    case unconfigured
    case unsupported
    case unknown
    case system(String)
}
