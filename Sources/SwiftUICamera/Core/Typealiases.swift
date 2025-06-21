//
//  Typealiases.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 21/06/25.
//

import Foundation

public typealias VoidCallback = @Sendable () -> Void

public typealias VoidCallbackWithError = @Sendable (SUICameraError?) -> Void

public typealias ResultCallback<T> = @Sendable (Result<T, SUICameraError>) -> Void

public typealias CapabilityChangeCallback = ResultCallback<any SUICameraCapability>?

public typealias JSON = [String: Any]
