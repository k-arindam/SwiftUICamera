//
//  CustomDivider.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 20/06/25.
//

import SwiftUI

internal struct CustomDivider: View {
    init(layout: Layout, thickness: Double = 1.0) {
        self.layout = layout
        self.thickness = thickness
    }
    
    let layout: Layout
    let thickness: Double
    
    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.3))
            .frame(maxWidth: layout == .vertical ? thickness : .infinity, maxHeight: layout == .vertical ? .infinity : thickness)
    }
    
    enum Layout {
        case horizontal
        case vertical
    }
}

#Preview {
    CustomDivider(layout: .horizontal)
}
