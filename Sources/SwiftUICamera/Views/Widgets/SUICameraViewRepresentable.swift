//
//  SUICameraViewRepresentable.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 20/06/25.
//

import SwiftUI

internal struct SUICameraViewRepresentable: UIViewRepresentable {
    public init(viewModel: SUICameraViewModel) {
        self.viewModel = viewModel
    }
    
    @ObservedObject private var viewModel: SUICameraViewModel
    
    func makeUIView(context: Context) -> some UIView {
        let view = PreviewLayerContainer()
        view.connect(with: viewModel)
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) { context.coordinator.update(with: uiView) }
    
    func makeCoordinator() -> SUICameraCoordinator { .init(self) }
    
    class SUICameraCoordinator: NSObject {
        init(_ parent: SUICameraViewRepresentable) {
            self.parent = parent
        }
        
        let parent: SUICameraViewRepresentable
        
        @MainActor func update(with view: UIViewType) -> Void {}
    }
}
