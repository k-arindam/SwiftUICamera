//
//  PublicMisc+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 21/06/25.
//

import Foundation

public extension SUICameraViewModel {
    func change(aspectRatio to: Int, completion: CapabilityChangeCallback = nil) -> Void {
        guard currentMode == .photo else { return }
    }
    
    func change(previewScale to: PreviewScale) -> Void {
        guard previewScale != to else { return }
        mainqueue.async {
            self.previewScale = to
        }
    }
    
    func switchMode(to mode: CameraMode) -> Void {
        self.switchMode(to: mode, releaseLock: true) { _ in }
    }
}
