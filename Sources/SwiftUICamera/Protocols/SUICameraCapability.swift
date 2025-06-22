//
//  SUICameraCapability.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 18/06/25.
//

import Foundation

public protocol SUICameraCapability: HashCodable, Identifiable, Sendable, CaseIterable {
    associatedtype T: HashCodable
    
    var rawValue: T { get }
}
