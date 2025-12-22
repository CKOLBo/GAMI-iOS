//
//  FloatingPlusButton.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//

import SwiftUI

struct FloatingPlusButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image("plus")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .padding(20)
                .background(Color("Blue1"))
                .cornerRadius(100)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FloatingPlusButton {
    }
}
