//
//  BoardHomeView..swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//


import SwiftUI

struct BoardHomeView: View {
    private let posts: [(title: String, preview: String, like: Int, comment: Int, imageName: String?)] = [
        ("제목제목김준표s", "내용내용내용김준표내용", 3, 0, nil),
        ("GSM에서 살아남는 방법", "제가 GSM에서 살아남는 방법을 알려 드리겠습니다!", 3, 0, nil),
        ("제목제목김준표s", "내용내용내용김준표내용", 3, 0, nil),
        ("제목제목김준표s", "내용내용내용김준표내용", 3, 0, nil),
        ("제목제목김준표s", "내용내용내용김준표내용", 3, 0, nil)
        
    ]
    @State private var searchText: String = ""
    @State private var isReportModalPresented: Bool = false
    @State private var reportReason: String = "개인정보 노출"
    @State private var reportDetail: String = ""
    @State private var isWritingPresented: Bool = false

    private let reportReasons: [String] = [
        "광고·홍보·스팸",
        "욕설·비하·혐오 표현",
        "개인정보 노출",
        "음란·불쾌한 내용",
        "게시판 목적과 맞지 않는 내용",
        "기타"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("익명게시판")
                            .font(.custom("Pretendard-Bold", size: 32))
                            .foregroundColor(Color.black)
                            .padding(.top, 60)
                            .padding(.leading, 32)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            BoardSearchBar(searchText: $searchText)
                                .padding(.leading, 31)
                                .padding(.trailing, 10)

                            NavigationLink {
                                MyPostsView(path: .constant(NavigationPath()))
                            } label: {
                                Text("내가 쓴 글")
                                    .font(.custom("Pretendard-Bold", size: 12))
                                    .foregroundColor(Color.white)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 13)
                                    .background(Color("Blue1"))
                                    .cornerRadius(24)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 10)

                        ForEach(Array(posts.enumerated()), id: \.offset) { _, p in
                            let post = BoardPostModel(
                                title: p.title,
                                subtitle: p.preview,
                                body: p.preview,
                                likeCount: p.like
                            )

                            NavigationLink {
                                BoardDetailView(post: post)
                            } label: {
                                BoardPostCard(
                                    title: p.title,
                                    preview: p.preview,
                                    likeCount: p.like,
                                    commentCount: p.comment,
                                    thumbnail: p.imageName == nil ? nil : Image(p.imageName!),
                                    onTapReport: {
                                        reportReason = "개인정보 노출"
                                        reportDetail = ""
                                        isReportModalPresented = true
                                    }
                                )
                            }
                            .padding(.horizontal, 31)
                            .padding(.top, 32)
                            .buttonStyle(.plain)
                            .disabled(isReportModalPresented)
                        }
                    }
                    .padding(.bottom, 140)
                }
                .ignoresSafeArea()
                 
                .buttonStyle(.plain)
                .padding(.bottom, 17)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .disabled(isReportModalPresented)

                if isReportModalPresented {

                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    ReportPostModalView(
                        selectedReason: $reportReason,
                        detailText: $reportDetail,
                        reasons: reportReasons,
                        onCancel: {
                            isReportModalPresented = false
                            reportReason = "개인정보 노출"
                            reportDetail = ""
                        },
                        onSubmit: {

                            isReportModalPresented = false
                            reportReason = "개인정보 노출"
                            reportDetail = ""
                        }
                    )
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .transition(.scale)
                }
                if !isReportModalPresented {
                    BoardFloatingPlusButton {
                        isWritingPresented = true
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: isReportModalPresented)
            .navigationDestination(isPresented: $isWritingPresented) {
                BoardwritingView()
            }
        }
    }
}

private struct BoardFloatingPlusButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color("Blue1"))
                    .frame(width: 62, height: 62)
                Image("plus")
                    
                    

            }
            .padding(.bottom, 20)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .buttonStyle(.plain)
     
    }
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
    }
}

#Preview {
    BoardHomeView()
}
