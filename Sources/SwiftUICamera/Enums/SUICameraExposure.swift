//
//  SUICameraExposure.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 18/06/25.
//

import CoreMedia

internal enum SUICameraExposure: Sendable {
    case auto
    case manual(duration: CMTime?, iso: Float?)
}
