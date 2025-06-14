//
//  SUICameraISO.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import Foundation

public enum SUICameraISO: Int, Codable, CaseIterable {
    case auto = 0
    case iso100 = 100
    case iso200 = 200
    case iso400 = 400
    case iso800 = 800
    case iso1600 = 1600
    case iso3200 = 3200
    case iso6400 = 6400
    case iso12800 = 12800
    case iso25600 = 25600
}
