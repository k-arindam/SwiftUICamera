//
//  SUICameraCapability.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 18/06/25.
//

import Foundation

public protocol SUICameraCapability: Codable, Hashable, Identifiable, Sendable, CaseIterable {
    associatedtype T: Hashable & Codable
    
    var rawValue: T { get }
}
