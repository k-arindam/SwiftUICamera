//
//  SUICameraView.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

import SwiftUI
import AVFoundation

public struct SUICameraView: View {
    public init(viewModel: SUICameraViewModel) {
        self.viewModel = viewModel
    }
    
    @ObservedObject private var viewModel: SUICameraViewModel
    
    public var body: some View {
        ZStack(alignment: .center) {
            SUICameraViewRepresentable(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if let bounds = viewModel.actualPreviewBounds {
                ZStack {
                    if viewModel.gridEnabled {
                        GridView()
                    }
                }
                .frame(maxWidth: bounds.width, maxHeight: bounds.height)
            }
        }
    }
}
