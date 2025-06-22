//
//  SUICameraFocus.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 22/06/25.
//

import Foundation

public enum SUICameraFocus: Float, SUICameraCapability {
    public typealias T = Float
    public var id: Float { rawValue }
    
    case auto = -1.00
    case f000 = 0.00
    case f010 = 0.10
    case f015 = 0.15
    case f020 = 0.20
    case f025 = 0.25
    case f030 = 0.30
    case f035 = 0.35
    case f040 = 0.40
    case f045 = 0.45
    case f050 = 0.50
    case f055 = 0.55
    case f060 = 0.60
    case f065 = 0.65
    case f070 = 0.70
    case f075 = 0.75
    case f080 = 0.80
    case f085 = 0.85
    case f090 = 0.90
    case f095 = 0.95
    case f100 = 1.00
}
