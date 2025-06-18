//
//  SUICameraShutterSpeed.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import Foundation

public enum SUICameraShutterSpeed: Int, SUICameraCapability {
    public typealias T = Int
    public var id: Int { rawValue }
    
    case auto = 0
    case ss1 = 1
    case ss2 = 2
    case ss4 = 4
    case ss8 = 8
    case ss15 = 15
    case ss30 = 30
    case ss60 = 60
    case ss125 = 125
    case ss250 = 250
    case ss500 = 500
    case ss1000 = 1000
    case ss2000 = 2000
    case ss4000 = 4000
    case ss8000 = 8000
}
