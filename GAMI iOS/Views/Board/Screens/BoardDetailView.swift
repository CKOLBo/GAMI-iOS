//
//  BoardDetailView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//


import SwiftUI

struct BoardPostModel: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let body: String
    let likeCount: Int

    init(id: UUID = UUID(), title: String, subtitle: String, body: String, likeCount: Int = 0) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.likeCount = likeCount
    }

    static let sample = BoardPostModel(
        title: "제목제목제목",
        subtitle: "부제목(미리보기)  내용이 들어갑니다.",
        body: "내용내용내용내용...",
        likeCount: 3
    )
}

struct BoardDetailView: View {
    let post: BoardPostModel
    @Environment(\.dismiss) private var dismiss
    @State private var commentText: String = ""
    @State private var comments: [String] = []
    @State private var likeCount: Int
    @State private var isLiked: Bool = false
    @FocusState private var isCommentFocused: Bool

    @State private var isReportModalPresented: Bool = false
    @State private var reportTargetComment: String? = nil
    @State private var reportReason: String = "개인정보 노출"
    @State private var reportDetail: String = ""

       private let reportReasons: [String] = [
        "광고·홍보·스팸",
        "욕설·비하·혐오 표현",
        "개인정보 노출",
        "음란·불쾌한 내용",
        "게시판 목적과 맞지 않는 내용",
        "기타"
    ]

    init(post: BoardPostModel) {
        self.post = post
        self._likeCount = State(initialValue: post.likeCount)
    }

    init() {
        self.init(post: .sample)
    }

    var body: some View {
        ZStack {
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

            Text(post.title)
                .font(.custom("Pretendard-Bold", size: 24))
                .foregroundColor(Color("Gray1"))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.leading, 32)
                .padding(.top, 28)
                .padding(.trailing, 32)
            
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

            Text(post.body)
                .font(.custom("Pretendard-Medium", size: 14))
                .foregroundColor(Color("Gray1"))
                .padding(.leading, 32)
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
                    reportTargetComment = nil
                    reportReason = "개인정보 노출"
                    reportDetail = ""
                    isReportModalPresented = true
                } label: {
                    Image("report")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .padding(10)
                }
                .contentShape(Rectangle())
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

            if isReportModalPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                ReportPostModalView(
                    selectedReason: $reportReason,
                    detailText: $reportDetail,
                    reasons: reportReasons,
                    onCancel: {
                        isReportModalPresented = false
                        reportTargetComment = nil
                        reportDetail = ""
                        isCommentFocused = false
                    },
                    onSubmit: {
                    
                        isReportModalPresented = false
                        reportTargetComment = nil
                        reportDetail = ""
                        isCommentFocused = false
                    }
                )
                .padding(.horizontal, 24)
                .transition(.scale)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isReportModalPresented)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }


private struct ReportPostModalView: View {
    @Binding var selectedReason: String
    @Binding var detailText: String
    let reasons: [String]
    let onCancel: () -> Void
    let onSubmit: () -> Void

    @FocusState private var isDetailFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("게시글 신고")
                .font(.custom("Pretendard-Bold", size: 20))
                .foregroundColor(Color("Gray1"))
                .padding(.top, 24)
                .padding(.horizontal, 24)

            Text("문제가 되는 이유를 선택 해주세요.\n허위 신고 시 이용이 제한할 수 있어요.")
                .font(.custom("Pretendard-Bold", size: 10))
                .foregroundColor(Color("Gray1"))
                .padding(.top, 12)
                .padding(.horizontal, 24)

            Menu {
                ForEach(reasons, id: \.self) { r in
                    Button {
                        selectedReason = r
                    } label: {
                        Text(r)
                    }
                }
            } label: {
                HStack(spacing: 0) {
                    Text(selectedReason)
                        .font(.custom("Pretendard-Medium", size: 14))
                        .foregroundColor(Color("Gray1"))

                    Spacer()

                    Image("qwe")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("Gray4"), lineWidth: 1)
                        )
                )
            }
            .padding(.top, 12)
            .padding(.horizontal, 24)

            Text("추가설명")
                .font(.custom("Pretendard-Bold", size: 10))
                .foregroundColor(Color("Gray1"))
                .padding(.top, 18)
                .padding(.horizontal, 24)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("Gray4"), lineWidth: 1)
                    )

                if detailText.isEmpty {
                    Text("어떤 점이 문제가 되는지 구체적으로 적어 주세요. (최대 300자)")
                        .font(.custom("Pretendard-Medium", size: 8))
                        .foregroundColor(Color("Gray3"))
                        .padding(.horizontal, 14)
                        .padding(.top, 10)
                }

                TextEditor(text: $detailText)
                    .font(.custom("Pretendard-Medium", size: 12))
                    .foregroundColor(Color("Gray1"))
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($isDetailFocused)
                    .onChange(of: detailText) { _, newValue in
                        if newValue.count > 300 {
                            detailText = String(newValue.prefix(300))
                        }
                    }
            }
            .frame(height: 180)
            .padding(.top, 10)
            .padding(.horizontal, 24)

            HStack(spacing: 12) {
                Button {
                    onCancel()
                } label: {
                    Text("취소")
                        .font(.custom("Pretendard-Bold", size: 14))
                        .foregroundColor(Color("Gray1"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color("Gray4"), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)

                Button {
                    onSubmit()
                } label: {
                    Text("신고하기")
                        .font(.custom("Pretendard-Bold", size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red.opacity(0.75))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 18)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: 520)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .onAppear {

        }
    }
}

}

#Preview {
    BoardDetailView(post: .sample)
}
