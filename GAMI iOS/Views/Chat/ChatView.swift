//
//  ChatView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/21/25.
//

import SwiftUI

struct ChatView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    ChatRoomView(title: "문강현")
                } label: {
                    Text("9기 문강현")
                }
            }
            .navigationTitle("채팅")
        }
    }
}

#Preview {
    ChatView()
}
