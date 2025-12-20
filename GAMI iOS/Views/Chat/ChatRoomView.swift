//
//  ChatRoom.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/21/25.
//

import SwiftUI



struct ChatRoomView: View {
    let title: String

    var body: some View {
        VStack {
            Text("aa")
                .font(.title2)

            Text("상대: \(title)")
                .foregroundStyle(.secondary)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ChatRoomView(title: "문강현")
    }
}
