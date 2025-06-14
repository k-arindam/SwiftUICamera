//
//  SUICameraError.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import Foundation

public enum SUICameraError: String, Error {
    case deviceUnavailable
    case unableToAttachDevice
    case unknown
}
