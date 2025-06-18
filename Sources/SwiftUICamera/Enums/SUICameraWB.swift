//
//  SUICameraWB.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import Foundation

public enum SUICameraWB: Int, SUICameraCapability {
    public typealias T = Int
    public var id: Int { rawValue }
    
    case auto = 0
    case wb2300 = 2300
    case wb2700 = 2700
    case wb3000 = 3000
    case wb3200 = 3200
    case wb4000 = 4000
    case wb5800 = 5800
    case wb6000 = 6000
    case wb6500 = 6500
    case wb7500 = 7500
    
    var tint: Float {
        switch self {
        case .auto:
            return 0
        case .wb2300:
            return 0.1
        case .wb2700:
            return 0.15
        case .wb3000:
            return 0.1
        case .wb3200:
            return 0.05
        case .wb4000:
            return -0.05
        case .wb5800:
            return 0.0
        case .wb6000:
            return 0.0
        case .wb6500:
            return 0.0
        case .wb7500:
            return -0.2
        }
    }
}
