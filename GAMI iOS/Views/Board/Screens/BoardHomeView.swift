//
//  BoardHomeView..swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//


import SwiftUI

struct BoardHomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<10, id: \.self) { _ in
                        NavigationLink {
                            BoardDetailView()
                        } label: {
                            BoardPostCard()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 31)
                .padding(.top, 16)
            }
        }
    }
}

#Preview {
    BoardHomeView()
}
