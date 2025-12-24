//
//  MentorCardView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/19/25.
//

import SwiftUI

struct MentorCardView: View {
    let mentor: MentorSummaryDTO
    let onApply: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {

            Image("profiles 1")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.top, 16)
                .padding(.leading, 8)

            VStack(alignment: .leading, spacing: 6) {
                Text(mentor.name)
                    .font(.custom("Pretendard-Bold", size: 12))
                    .foregroundColor(Color("Gray1"))

                HStack(spacing: 4) {
                    Text("\(mentor.generation)기")
                        .font(.custom("Pretendard-Bold", size: 10))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color("Blue1"))
                        .cornerRadius(4)

                    Text(mentor.major)
                        .font(.custom("Pretendard-Bold", size: 10))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color("Purple1"))
                        .cornerRadius(4)
                }
                .layoutPriority(1)
            }
            .padding(.top, 20)

            Spacer()
        }
        .frame(width: 162, height: 140, alignment: .topLeading)
        .background(.white)
        .cornerRadius(12)
        .cornerRadius(12)
        .shadow(
            color: .black.opacity(0.1),
            radius: 12,
            x: 0, y: 6
        )

        .overlay(alignment: .bottomTrailing) {
            Button(action: onApply) {
                Text("멘토 신청")
                    .padding(.vertical, 11.5)
                    .padding(.horizontal, 9)
                    .background(Color("White1"))
                    .cornerRadius(8)
                    .font(.custom("Pretendard-Bold", size: 12))
                    .foregroundColor(Color("Gray1"))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 12)
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    MentorCardView(
        mentor: MentorSummaryDTO(
            memberId: 1,
            name: "양은준",
            gender: "MALE",
            generation: 9,
            major: "FRONTEND"
        ),
        onApply: {
            print("멘토 신청")
        }
    )
}
