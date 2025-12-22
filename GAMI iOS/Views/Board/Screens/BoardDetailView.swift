//
//  BoardDetailView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//

import SwiftUI

struct BoardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var commentText: String = ""
    @State private var comments: [String] = []
    @State private var likeCount: Int = 3
    @State private var isLiked: Bool = false
    @FocusState private var isCommentFocused: Bool


    var body: some View {
        ScrollView {
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
            }    .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.leading, 12)
                .padding(.top, 16)
            
            Text("익명 게시판")
                .font(.custom("Pretendard-Bold", size: 32))
                .foregroundColor(Color.black)
                .padding(.leading, 32)
                .padding(.top, 16)
            
            Text("제목제목제목")
                .font(.custom("Pretendard-Bold", size: 24))
                .foregroundColor(Color("Gray1"))
                .padding(.leading, 24)
                .padding(.top, 28)
            
            Rectangle()
                .fill(Color("Gray2"))
                .frame(height: 1)
                .padding(.horizontal, 16)
                .padding(.top, 24)
            
            HStack(spacing: 0){
                Image("profiles 1")
                    .padding(.top, 16)
                    .padding(.leading, 32)
                    .padding(.trailing, 14)
                
                Text("익명")
                    .font(.custom("Pretendard-Bold", size: 16))
                    .foregroundColor(Color("Gray1"))
                    .padding(.top, 16)
            }
            
            Text("내용내용내용내용내욘애뇨ㅐ뇨요내용내용낸요요내요내ㅛ내ㅛ내요ㅐ뇨애뇨ㅐ내용낸요요내욘ㅇ내요요내요요내용내요요내용내용내용ㄴ내용내용ㄴ내용ㄴ용낸용내용내용내용네용내용내용내용내용")
                .padding(.leading, 40)
                .padding(.trailing, 32)
                .padding(.top, 16)
            
            HStack(spacing: 0) {
                Button {
                    if isLiked {
                        isLiked = false
                        likeCount = max(0, likeCount - 1)
                    } else {
                        isLiked = true
                        likeCount += 1
                    }
                } label: {
                    Image("Hart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 14)
                }
                .buttonStyle(.plain)
                .padding(.leading, 40)
                .padding(.top, 10)
                .padding(.trailing, 10)

                Text("\(likeCount)")
                    .padding(.top, 10)
                    .padding(.trailing, 36)

                Button {
                } label: {
                    Image("report")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
            }
            
            
            Rectangle()
                .fill(Color("Gray2"))
                .frame(height: 1)
                .padding(.horizontal, 16)
                .padding(.top, 15)
            
            HStack(spacing: 0){
                Image("Text")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .padding(.leading, 31)
                    .padding(.trailing, 8)
                    .padding(.top, 15)

                Text("댓글 \(comments.count)개")
                    .font(.custom("Pretendard-SemiBold", size: 14))
                    .foregroundColor(Color("Gray1"))
                    .padding(.top, 15)
            }
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("White1"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("Gray4"), lineWidth: 1)
                        )

                    if commentText.isEmpty {
                        Text("댓글을 입력하세요")
                            .font(.custom("Pretendard-Medium", size: 12))
                            .foregroundColor(Color("Gray3"))
                            .padding(.leading, 12)
                            .padding(.top, 12)
                    }

                    TextEditor(text: $commentText)
                        .font(.custom("Pretendard-Medium", size: 12))
                        .foregroundColor(Color("Gray1"))
                        .focused($isCommentFocused)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .frame(height: 90)

                HStack(spacing: 8) {
                    Spacer()

                    Button {
                        commentText = ""
                        isCommentFocused = false
                    } label: {
                        Text("취소")
                            .font(.custom("Pretendard-SemiBold", size: 12))
                            .foregroundColor(Color("Gray3"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)

                    Button {
                        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        comments.append(trimmed)
                        commentText = ""
                        isCommentFocused = false
                    } label: {
                        Text("댓글")
                            .font(.custom("Pretendard-SemiBold", size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color("Gray4") : Color("Blue1"))
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            if !comments.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(comments.enumerated()), id: \.offset) { _, c in
                        HStack(alignment: .top, spacing: 12) {
                            Image("profiles 1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28, alignment: .top)


                            VStack(alignment: .leading, spacing: 4) {
                                Text("익명")
                                    .font(.custom("Pretendard-Bold", size: 12))
                                    .foregroundColor(Color("Gray1"))

                                Text(c)
                                    .font(.custom("Pretendard-Medium", size: 12))
                                    .foregroundColor(Color("Gray3"))
                            }

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("White1"))
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 16)
            }


            }
            .padding(.bottom, 24)
       
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct BoardDetailViewInner: View {
    let comments: [String]

    var body: some View {
        BoardDetailViewContent(comments: comments)
    }
}

private struct BoardDetailViewContent: View {
    let comments: [String]

    var body: some View {
        BoardDetailView()
            .onAppear { }
    }
}

private struct BoardDetailViewPreview: View {
    var body: some View {
        BoardDetailViewWrapper()
    }
}

private struct BoardDetailViewWrapper: View {
    @State private var seeded = false
    @State private var comments: [String] = []

    var body: some View {
        BoardDetailViewHost(comments: $comments)
            .onAppear {
                guard !seeded else { return }
                seeded = true
                comments = [
                    "와 이 글 공감돼요…",
                    "댓글 테스트 2",
                    "세 번째 댓글! 길게 써도 카드가 잘 늘어나는지 확인"
                ]
            }
    }
}

private struct BoardDetailViewHost: View {
    @Binding var comments: [String]

    var body: some View {
        BoardDetailViewInner(comments: comments)
    }
}

#Preview {
    BoardDetailViewPreview()
}
