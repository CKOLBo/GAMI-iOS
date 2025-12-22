//
//  BoardPostCard.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//

import SwiftUI

struct BoardPostCard: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 0) {
                    Image("Back")
                        .padding(.trailing, 8)
                    Text("돌아가기")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(Color("Gray3"))
                }
            }
        }
    }
}

#Preview {
    BoardPostCard()
}
