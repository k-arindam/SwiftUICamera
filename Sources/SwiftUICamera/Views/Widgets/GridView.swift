//
//  GridView.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 20/06/25.
//

import SwiftUI

internal struct GridView: View {
    @ViewBuilder private func buildLines(_ layout: CustomDivider.Layout) -> some View {
        Spacer()
        CustomDivider(layout: layout)
        Spacer()
        CustomDivider(layout: layout)
        Spacer()
    }
    
    var body: some View {
        ZStack {
            VStack { buildLines(.horizontal) }
            HStack { buildLines(.vertical) }
        }
    }
}

#Preview {
    GridView()
}
