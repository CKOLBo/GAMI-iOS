//
//  BoardPostCard.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//

import SwiftUI

struct BoardPostCard: View {
    let postId: Int
    let title: String
    let preview: String
    @State private var likeCount: Int
    @State private var isLiked: Bool = false
    @State private var isLikeLoading: Bool = false
    // ✅ 부모(BoardHomeView)의 posts 배열을 업데이트하기 위한 콜백
    // liked/likeCount가 바뀔 때마다 호출
    let onTapLike: (_ liked: Bool, _ likeCount: Int) -> Void
    private let postService = PostService()

    // ✅ APIClient 에러 타입이 프로젝트마다 달라서, 문자열 기반으로 HTTP 상태코드 추출
    private func isHTTPStatus(_ error: Error, _ code: Int) -> Bool {
        let desc = String(describing: error)
        if desc.contains("httpStatus(\(code)") { return true }
        if desc.contains("status=\(code)") { return true }
        if error.localizedDescription.contains("HTTP \(code)") { return true }
        return false
    }

    // ✅ BoardPostDetailDTO 내부에 isLiked(또는 liked) 필드가 있을 수도 있어서 best-effort로 추출
    private func extractIsLiked(from value: Any?) -> Bool? {
        guard let value else { return nil }
        let m = Mirror(reflecting: value)
        if let v = m.children.first(where: { $0.label == "isLiked" })?.value as? Bool { return v }
        if let v = m.children.first(where: { $0.label == "liked" })?.value as? Bool { return v }
        if let v = m.children.first(where: { $0.label == "isLike" })?.value as? Bool { return v }
        return nil
    }

    let commentCount: Int
    let thumbnail: Image?
    let thumbnailURL: String?
    let onTapReport: () -> Void

    init(
        postId: Int,
        title: String,
        preview: String,
        likeCount: Int = 0,
        commentCount: Int = 0,
        thumbnail: Image? = nil,
        thumbnailURL: String? = nil,
        onTapLike: @escaping (_ liked: Bool, _ likeCount: Int) -> Void = { _, _ in },
        onTapReport: @escaping () -> Void = {}
    ) {
        self.postId = postId
        self.title = title
        self.preview = preview
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.thumbnail = thumbnail
        self.thumbnailURL = thumbnailURL
        self.onTapLike = onTapLike
        self.onTapReport = onTapReport
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
                    Button {
                        guard !isLikeLoading else { return }

                        let nextLiked = !isLiked

                        // Optimistic UI
                        isLiked = nextLiked
                        if nextLiked {
                            likeCount += 1
                        } else {
                            likeCount = max(0, likeCount - 1)
                        }
                        onTapLike(isLiked, likeCount)
                        NotificationCenter.default.post(
                            name: Notification.Name("boardLikeChanged"),
                            object: nil,
                            userInfo: [
                                "postId": postId,
                                "isLiked": isLiked,
                                "likeCount": likeCount
                            ]
                        )

                        isLikeLoading = true
                        Task {
                            do {
                                if nextLiked {
                                    try await postService.likePost(postId: postId)
                                } else {
                                    try await postService.unlikePost(postId: postId)
                                }
                            } catch {
                                await MainActor.run {
                                    // ✅ 서버가 이미 해당 상태라면(409/404) 로컬 상태 유지하고 종료
                                    if nextLiked {
                                        if isHTTPStatus(error, 409) {
                                            isLikeLoading = false
                                            return
                                        }
                                    } else {
                                        if isHTTPStatus(error, 404) || isHTTPStatus(error, 409) {
                                            isLikeLoading = false
                                            return
                                        }
                                    }

                                    // ✅ 진짜 실패면 롤백
                                    isLiked.toggle()
                                    if nextLiked {
                                        likeCount = max(0, likeCount - 1)
                                    } else {
                                        likeCount += 1
                                    }
                                    onTapLike(isLiked, likeCount)
                                    isLikeLoading = false
                                }
                                print("❌ 좋아요 서버통신 실패:")
                                print(String(describing: error))
                                return
                            }

                            await MainActor.run {
                                isLikeLoading = false
                            }
                        }
                    } label: {
                        HStack(spacing: 0) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                                .foregroundColor(isLiked ? .red : Color("Gray1"))

                            Text("\(likeCount)")
                                .font(.custom("Pretendard-Regular", size: 12))
                                .foregroundColor(Color("Gray1"))
                                .padding(.horizontal, 14)
                        }
                    }
                    .buttonStyle(.borderless)
                    .disabled(isLikeLoading)

                    HStack(spacing: 0) {
                        Image("Text")
                        Text("\(commentCount)")
                            .font(.custom("Pretendard-Regular", size: 12))
                            .foregroundColor(Color("Gray1"))
                            .padding(.horizontal, 14)
                    }

                    Button {
                        onTapReport()
                    } label: {
                        Image("report")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .padding(10)
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)

            // ✅ 우선순위: (1) 로컬 Image(프리뷰/샘플) -> (2) 서버 URL -> (3) 플레이스홀더
            if let thumbnail = thumbnail {
                thumbnail
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if let thumbnailURL, let url = URL(string: thumbnailURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Gray4"))
                            .opacity(0.25)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Gray4"))
                            .opacity(0.25)
                    @unknown default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("Gray4"))
                            .opacity(0.25)
                    }
                }
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
        BoardPostCard(
            postId: 1,
            title: "제목제목김준표s",
            preview: "내용내용내용김준표내용",
            likeCount: 3,
            commentCount: 0,
            thumbnail: Image("sample"),
            onTapReport: {}
        )

        BoardPostCard(
            postId: 2,
            title: "GSM에서 살아남는 방법",
            preview: "제가 GSM에서 살아남는 방법을 알려 드리겠습니다!",
            likeCount: 3,
            commentCount: 0,
            onTapReport: {}
        )
    }
    .padding(24)
    .background(Color.white)
}
