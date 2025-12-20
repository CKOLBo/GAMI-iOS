//
//  MentorEmptyView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/19/25.
//

import SwiftUI

struct MentorEmptyView: View {
    var body: some View {
        VStack(spacing: 18) {
            Image("find 1")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .foregroundColor(Color("Gray2"))

            VStack(spacing: 6) {
                Text("일치하는 멘토를 찾지 못했어요")
                    .font(.custom("Pretendard-Bold", size: 16))
                    .foregroundColor(Color("Gray1"))
                

                Text("멘토를 추천 받아 볼까요?")
                    .font(.custom("Pretendard-Bold", size: 16))
                    .foregroundColor(Color("Gray1"))
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 54)
    }
}

#Preview {
    MentorEmptyView()
}
