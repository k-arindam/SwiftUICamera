//
//  SUICameraView.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import SwiftUI
import AVFoundation

public struct SUICameraView: UIViewRepresentable {
    public init(viewModel: SUICameraViewModel, scale: Scale = .fit) {
        self.viewModel = viewModel
        self.scale = scale
    }
    
    @ObservedObject private var viewModel: SUICameraViewModel
    
    let scale: Scale
    
    public func makeUIView(context: Context) -> some UIView {
        let preview = context.coordinator.preview
        preview.videoGravity = scale.videoGravity
        preview.session = viewModel.session
        
        let view = UIView()
        view.layer.addSublayer(preview)
        view.isOpaque = true
        
        return view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.update(with: uiView)
        
        let preview = context.coordinator.preview
        let bounds = uiView.bounds
        
        preview.frame = bounds
        preview.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    public func makeCoordinator() -> SUICameraCoordinator { .init(self) }
    
    public class SUICameraCoordinator: NSObject {
        init(_ parent: SUICameraView) {
            self.parent = parent
        }
        
        let parent: SUICameraView
        let preview = AVCaptureVideoPreviewLayer()
        
        @MainActor func update(with view: UIViewType) -> Void {}
    }
    
    public enum Scale {
        case fit
        case fill
        
        var videoGravity: AVLayerVideoGravity {
            switch self {
            case .fit:
                return .resizeAspect
            case .fill:
                return .resizeAspectFill
            }
        }
    }
}
