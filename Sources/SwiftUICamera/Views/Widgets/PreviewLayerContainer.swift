//
//  PreviewLayerContainer.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

import UIKit
import AVFoundation
@preconcurrency import Combine

internal class PreviewLayerContainer: UIView {
    private var layoutDrawCounter: Int = 0
    private var viewModel: SUICameraViewModel? = nil
    private var cancellables = Set<AnyCancellable>()
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    internal var preview: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if layoutDrawCounter <= 2 {
            updatePreview()
            layoutDrawCounter += 1
        }
    }
    
    internal func connect(with viewModel: SUICameraViewModel) {
        self.preview.session = viewModel.session
        self.viewModel = viewModel
        
        viewModel.$deviceOrientation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updatePreview() }
            .store(in: &cancellables)
        
        viewModel.$previewScale
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scale in self?.preview.videoGravity = scale.videoGravity }
            .store(in: &cancellables)
    }
    
    private func updatePreview() -> Void {
        debugPrint("----->>> updatePreview() !!!")
        
        guard let viewModel, let connection = preview.connection else { return }
        viewModel.previewBounds = self.preview.bounds
        
        let rotation = viewModel.videoRotationAngle
        
        if connection.isVideoRotationAngleSupported(rotation) {
            connection.videoRotationAngle = rotation
        }
    }
    
    deinit {
        cancellables.removeAll()
    }
}
