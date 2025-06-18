//
//  SUICameraView.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import SwiftUI
import AVFoundation

public struct SUICameraView: UIViewRepresentable {
    public init(viewModel: SUICameraViewModel) {
        self.viewModel = viewModel
    }
    
    @ObservedObject private var viewModel: SUICameraViewModel
    
    public func makeUIView(context: Context) -> some UIView {
        let view = PreviewLayerContainer()
        view.connect(with: viewModel)
        
        return view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) { context.coordinator.update(with: uiView) }
    
    public func makeCoordinator() -> SUICameraCoordinator { .init(self) }
    
    public class SUICameraCoordinator: NSObject {
        init(_ parent: SUICameraView) {
            self.parent = parent
        }
        
        let parent: SUICameraView
        
        @MainActor func update(with view: UIViewType) -> Void {}
    }
}
