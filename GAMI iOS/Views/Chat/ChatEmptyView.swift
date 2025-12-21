//
//  ChatEmptyView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/21/25.
//

import SwiftUI

struct ChatEmptyView: View {
    var body: some View {
        VStack(spacing: 18) {
            Image("find 1")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .foregroundColor(Color("Gray2"))

            VStack(spacing: 6) {
                Text("일치하는 사용자를 찾지 못했어요")
                    .font(.custom("Pretendard-Bold", size: 16))
                    .foregroundColor(Color("Gray1"))
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        
    }
}

#Preview {
    ChatEmptyView()
}
