//
//  MyPostCard.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//

import SwiftUI

struct MyPostCard: View {
    
    let title: String
    let preview: String
    let likeCount: Int
    let commentCount: Int
    let onTapReport: (() -> Void)?
    let thumbnail: Image?

    @State private var isLiked: Bool = false

    init(
        title: String,
        preview: String,
        likeCount: Int = 0,
        commentCount: Int = 0,
        onTapReport: (() -> Void)? = nil,
        thumbnail: Image? = nil
    ) {
        self.title = title
        self.preview = preview
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.onTapReport = onTapReport
        self.thumbnail = thumbnail
    }

    
    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.custom("Pretendard-Bold", size: 16))
                    .foregroundColor(Color("Gray1"))
                    .lineLimit(1)
                    .padding(.bottom, 10)

                HStack(spacing: 0) {
                    Text("익명")
                        .font(.custom("Pretendard-SemiBold", size: 10))
                        .foregroundColor(Color("Gray1"))

                    Text(":")
                        .font(.custom("Pretendard-SemiBold", size: 10))
                        .foregroundColor(Color("Gray3"))
                        .padding(.horizontal, 2)

                    Text(preview)
                        .font(.custom("Pretendard-SemiBold", size: 10))
                        .foregroundColor(Color("Gray3"))
                        .lineLimit(1)
                        
                }
                .padding(.bottom, 20)

                HStack(spacing: 0) {
                    HStack(spacing: 6) {
                        Button {
                            isLiked.toggle()
                        } label: {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                                .foregroundColor(isLiked ? .red : Color("Gray1"))
                        }
                        .buttonStyle(.plain)

                        Text("\(likeCount + (isLiked ? 1 : 0))")
                            .font(.custom("Pretendard-Regular", size: 12))
                            .foregroundColor(Color("Gray1"))
                            .padding(.leading, 6)
                            .padding(.trailing, 14)
                    }

                    HStack(spacing: 0) {
                        Image("Text")
                        Text("\(commentCount)")
                            .font(.custom("Pretendard-Regular", size: 12))
                            .foregroundColor(Color("Gray1"))
                            .padding(.horizontal, 14)
                    }

                    if let onTapReport {
                        Button {
                            onTapReport()
                        } label: {
                            Image("report")
                        }
                        .buttonStyle(.plain)
                    } else {
                        Image("report")
                    }
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)

            if let thumbnail = thumbnail {
                thumbnail
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("Gray4"))
                    .frame(width: 88, height: 88)
                    .opacity(0.25)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    VStack(spacing: 16) {
        MyPostCard(
            title: "제목제목김준표s",
            preview: "내용내용내용김준표내용",
            likeCount: 3,
            commentCount: 0,
            thumbnail: Image("sample")
        )

        BoardPostCard(
            postId: 2,
            title: "GSM에서 살아남는 방법",
            preview: "제가 GSM에서 살아남는 방법을 알려 드리겠습니다!",
            likeCount: 3,
            commentCount: 0
        )
    }
    .padding(24)
    .background(Color.white)
}
