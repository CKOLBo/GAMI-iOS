//
//  BoardDetailView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//




import SwiftUI
import UIKit


// MARK: - Comment DTO / API (Board)

private struct BoardCommentResponseDTO: Decodable, Identifiable, Hashable {
    let postId: Int
    let commentId: Int
    let comment: String
    let createdAt: String

    var id: Int { commentId }
}

private struct BoardCreateCommentRequestDTO: Encodable {
    let comment: String
}

private enum BoardCommentAPI: Endpoint {
    case fetch(postId: Int)
    case create(postId: Int, body: BoardCreateCommentRequestDTO)
    case delete(commentId: Int)

    var method: HTTPMethod {
        switch self {
        case .fetch:
            return .get
        case .create:
            return .post
        case .delete:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .fetch(let postId):
            return "/api/post/\(postId)/comment"
        case .create(let postId, _):
            return "/api/post/\(postId)/comment"
        case .delete(let commentId):
            return "/api/post/comment/\(commentId)"
        }
    }

    var queryItems: [URLQueryItem] { [] }

    var headers: [String : String] {
        var h: [String: String] = [
            "Content-Type": "application/json"
        ]
        if let token = UserDefaults.standard.string(forKey: "accessToken"), !token.isEmpty {
            h["Authorization"] = "Bearer \(token)"
        }
        return h
    }

    var body: Data? {
        switch self {
        case .create(_, let body):
            return try? JSONEncoder().encode(body)
        default:
            return nil
        }
    }
}

private struct BoardEmptyResponseDTO: Decodable {}

private final class BoardCommentService {
    private let client = APIClient.shared

    func fetch(postId: Int) async throws -> [BoardCommentResponseDTO] {
        try await client.request(BoardCommentAPI.fetch(postId: postId))
    }

    func create(postId: Int, comment: String) async throws -> BoardCommentResponseDTO {
        let body = BoardCreateCommentRequestDTO(comment: comment)
        return try await client.request(BoardCommentAPI.create(postId: postId, body: body))
    }

    func delete(commentId: Int) async throws {
        let _: BoardEmptyResponseDTO = try await client.request(BoardCommentAPI.delete(commentId: commentId))
    }
}

struct BoardPostModel: Identifiable, Hashable {

    let id: Int
    let title: String
    let subtitle: String
    let body: String
    let imageURLs: [String]
    let likeCount: Int

    init(id: Int = -1, title: String, subtitle: String, body: String, likeCount: Int = 0, imageURLs: [String] = []) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.imageURLs = imageURLs
        self.likeCount = likeCount
    }

    static let sample = BoardPostModel(
        id: -1,
        title: "제목제목제목",
        subtitle: "부제목(미리보기)  내용이 들어갑니다.",
        body: "내용내용내용내용...",
        likeCount: 3,
        imageURLs: []
    )
}

struct BoardDetailView: View {
    let post: BoardPostModel
    private let postService = PostService()
    // ✅ 앱 전역(공유) 좋아요 상태 저장소 (Home / BoardHome / Detail 공통)
    @StateObject private var likeStore = BoardLikeStore.shared
    @State private var detail: BoardPostDetailDTO? = nil
    @State private var isDetailLoading: Bool = false
    @State private var detailErrorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var commentText: String = ""
    private let commentService = BoardCommentService()
    @State private var comments: [BoardCommentResponseDTO] = []
    @State private var isCommentsLoading: Bool = false
    @State private var commentErrorMessage: String? = nil
    @State private var likeCount: Int
    @State private var isLiked: Bool = false
    @State private var isLikeLoading: Bool = false
    @State private var likeErrorMessage: String? = nil
    @FocusState private var isCommentFocused: Bool

    // ✅ 재미나이 글 요약 (서버 요약)
    @State private var isSummaryModalPresented: Bool = false
    @State private var isSummaryLoading: Bool = false
    @State private var summaryText: String = ""
    @State private var summaryErrorMessage: String? = nil
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
        // ✅ Store 값이 있으면 그게 우선(다른 화면에서 이미 눌렀을 수 있음)
        let storedCount = BoardLikeStore.shared.likeCount(for: post.id, fallback: post.likeCount)
        let storedLiked = BoardLikeStore.shared.isLiked(post.id)
        self._likeCount = State(initialValue: storedCount)
        self._isLiked = State(initialValue: storedLiked)
    }


    private var displayTitle: String { detail?.title ?? post.title }
    private var displayBody: String { detail?.content ?? post.body }

    // MARK: - Summary

    private func generateLocalSummary(from text: String) -> String {
        let trimmed = text
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { return "요약할 내용이 없어요." }

        let separators = CharacterSet(charactersIn: ".!?。！？")
        let pieces = trimmed
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if pieces.isEmpty {
            return String(trimmed.prefix(160)) + (trimmed.count > 160 ? "…" : "")
        }

        let takeCount = min(3, max(2, pieces.count >= 2 ? 2 : 1))
        let joined = pieces.prefix(takeCount).joined(separator: ". ")

        let maxLen = 220
        if joined.count > maxLen {
            return String(joined.prefix(maxLen)) + "…"
        }
        return joined + (joined.hasSuffix(".") ? "" : ".")
    }

    @MainActor
    private func openSummary() {
        guard post.id > 0 else {
            summaryErrorMessage = "postId가 올바르지 않아요. (id=\(post.id))"
            isSummaryModalPresented = true
            return
        }

        summaryErrorMessage = nil
        summaryText = ""
        isSummaryModalPresented = true
        isSummaryLoading = true

        Task {
            do {
                let res = try await postService.fetchPostSummary(postId: post.id)
                await MainActor.run {
                    summaryText = res.summary
                    isSummaryLoading = false
                }
            } catch {
                let fallback = generateLocalSummary(from: displayBody)
                await MainActor.run {
                    summaryText = fallback

                    if isHTTPStatus(error, 409) {
                        // ✅ 서버에 요약이 아직 없을 때(정상 케이스)
                        summaryErrorMessage = "아직 서버 요약이 없어서 로컬 요약으로 보여줘요."
                    } else {
                        // 그 외는 네트워크/서버 에러
                        summaryErrorMessage = "서버 요약을 불러오지 못했어요. 로컬 요약으로 보여줄게요."
                    }

                    isSummaryLoading = false
                }
            }
        }
    }

    @MainActor
    private func closeSummary() {
        isSummaryModalPresented = false
        isSummaryLoading = false
        summaryErrorMessage = nil
    }

    @MainActor
    private func copySummaryToClipboard() {
        let trimmed = summaryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        UIPasteboard.general.string = trimmed
    }

    // MARK: - Images (best-effort extraction)

    private var displayImageURLs: [String] {
        let detailURLs = extractImageURLs(from: detail)
        if !detailURLs.isEmpty { return detailURLs }
        return post.imageURLs
    }

    /// BoardPostDetailDTO의 필드 구조가 보이는 범위 밖일 수 있어서, 런타임 리플렉션으로 images[*].imageUrl을 최대한 뽑아냄
    private func extractImageURLs(from value: Any?) -> [String] {
        guard let value else { return [] }

        // detail.images
        let m = Mirror(reflecting: value)
        guard let imagesAny = m.children.first(where: { $0.label == "images" })?.value else {
            return []
        }

        // images: [Something]
        var urls: [String] = []

        // Swift 배열은 Any로 캐스팅이 잘 안 될 수 있어서 Mirror로 한 번 더 순회
        let imagesMirror = Mirror(reflecting: imagesAny)
        if imagesMirror.displayStyle == .collection {
            for child in imagesMirror.children {
                let item = child.value

                // images가 [String]인 경우
                if let s = item as? String {
                    urls.append(s)
                    continue
                }

                let itemMirror = Mirror(reflecting: item)

                // imageUrl 또는 url
                if let url = itemMirror.children.first(where: { $0.label == "imageUrl" })?.value as? String {
                    urls.append(url)
                } else if let url = itemMirror.children.first(where: { $0.label == "url" })?.value as? String {
                    urls.append(url)
                }
            }
        }

        return urls
    }

    // ✅ BoardPostDetailDTO 안에 "내가 좋아요 했는지" 필드명이 프로젝트마다 달라서, 리플렉션으로 최대한 Bool을 찾아봄
    private func extractIsLiked(from value: Any?) -> Bool? {
        guard let value else { return nil }

        let m = Mirror(reflecting: value)
        let candidates = [
            "isLiked", "liked", "likedByMe", "myLike", "isLike", "likeYn", "isLikeYn", "likeStatus"
        ]

        for key in candidates {
            if let v = m.children.first(where: { $0.label == key })?.value {
                if let b = v as? Bool { return b }
                if let i = v as? Int { return i != 0 }
                if let s = v as? String {
                    let lower = s.lowercased()
                    if lower == "y" || lower == "yes" || lower == "true" || lower == "1" { return true }
                    if lower == "n" || lower == "no" || lower == "false" || lower == "0" { return false }
                }
            }
        }

        return nil
    }

    // ✅ APIClient 에러 타입이 프로젝트마다 다를 수 있어서, 문자열 기반으로 HTTP 상태코드를 최대한 판별
    private func isHTTPStatus(_ error: Error, _ code: Int) -> Bool {
        let desc = String(describing: error)
        if desc.contains("httpStatus(\(code)") { return true }
        if desc.contains("status=\(code)") { return true }
        if error.localizedDescription.contains("HTTP \(code)") { return true }
        return false
    }


    @MainActor
    private func notifyLikeChanged() {
        guard post.id > 0 else { return }

        // ✅ Store 갱신 (Single Source of Truth)
        likeStore.apply(postId: post.id, isLiked: isLiked, likeCount: likeCount)

        // ✅ 모든 화면에 동기화 신호
        NotificationCenter.default.post(
            name: Notification.Name("boardLikeChanged"),
            object: nil,
            userInfo: [
                "postId": post.id,
                "isLiked": isLiked,
                "likeCount": likeCount
            ]
        )
    }

    @MainActor
    private func notifyCommentCountChanged() {
        guard post.id > 0 else { return }
        NotificationCenter.default.post(
            name: .boardCommentCountChanged,
            object: nil,
            userInfo: [
                "postId": post.id,
                "commentCount": comments.count
            ]
        )
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

            if isDetailLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("불러오는 중...")
                        .font(.custom("Pretendard-Medium", size: 12))
                        .foregroundColor(Color("Gray3"))
                }
                .padding(.leading, 32)
                .padding(.top, 8)
            }

            if let detailErrorMessage {
                Text(detailErrorMessage)
                    .font(.custom("Pretendard-Medium", size: 12))
                    .foregroundColor(.red)
                    .padding(.leading, 32)
                    .padding(.top, 8)
                    .padding(.trailing, 32)
            }

            if let likeErrorMessage {
                Text(likeErrorMessage)
                    .font(.custom("Pretendard-Medium", size: 12))
                    .foregroundColor(.red)
                    .padding(.leading, 32)
                    .padding(.top, 6)
                    .padding(.trailing, 32)
            }

            Text(displayTitle)
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

            // ✅ 게시글 이미지 (서버 imageUrl)
            if !displayImageURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(displayImageURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color("Gray4"))
                                            .opacity(0.25)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color("Gray4"))
                                            .opacity(0.25)
                                    @unknown default:
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color("Gray4"))
                                            .opacity(0.25)
                                    }
                                }
                                .frame(width: 260, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                }
            }

            Text(displayBody)
                .font(.custom("Pretendard-Medium", size: 14))
                .foregroundColor(Color("Gray1"))
                .padding(.leading, 32)
                .padding(.trailing, 32)
                .padding(.top, 16)
            
            HStack(spacing: 0) {
                Button {
                    guard post.id > 0 else {
                        likeErrorMessage = "postId가 올바르지 않아요. (id=\(post.id))"
                        print("❌ like tap blocked: invalid postId=", post.id)
                        return
                    }
                    guard !isLikeLoading else { return }

                    likeErrorMessage = nil

                    let nextLiked = !isLiked
                    print("❤️ like tap postId=\(post.id) nextLiked=\(nextLiked)")

                    // ✅ Optimistic UI
                    isLiked = nextLiked
                    if nextLiked {
                        likeCount += 1
                    } else {
                        likeCount = max(0, likeCount - 1)
                    }
                    notifyLikeChanged()

                    isLikeLoading = true
                    Task {
                        do {
                            if nextLiked {
                                print("➡️ like API / postId=\(post.id)")
                                try await postService.likePost(postId: post.id)
                            } else {
                                print("➡️ unlike API / postId=\(post.id)")
                                try await postService.unlikePost(postId: post.id)
                            }
                            await MainActor.run {
                                isLikeLoading = false
                            }
                            // NOTE: Do NOT re-fetch detail immediately here.
                            // The server may return stale likeCount right after mutation, which overwrites our optimistic UI.
                            // Home sync is handled via NotificationCenter (`notifyLikeChanged()`).
                            print("✅ like API success postId=\(post.id) liked=\(nextLiked) likeCount=\(likeCount)")
                        } catch {
                            await MainActor.run {
                                // 서버가 이미 해당 상태인 경우(409/404)는 "성공"으로 보고 로컬 상태 유지
                                if nextLiked {
                                    if isHTTPStatus(error, 409) {
                                        // already liked
                                        isLiked = true
                                        likeErrorMessage = nil
                                        isLikeLoading = false
                                        notifyLikeChanged()
                                        return
                                    }
                                } else {
                                    if isHTTPStatus(error, 404) || isHTTPStatus(error, 409) {
                                        // already unliked
                                        isLiked = false
                                        likeErrorMessage = nil
                                        isLikeLoading = false
                                        notifyLikeChanged()
                                        return
                                    }
                                }

                                // 그 외 진짜 실패면 롤백
                                isLiked.toggle()
                                if nextLiked {
                                    likeCount = max(0, likeCount - 1)
                                } else {
                                    likeCount += 1
                                }
                                notifyLikeChanged()
                                likeErrorMessage = "좋아요 처리에 실패했어요.\n\(error.localizedDescription)"
                                isLikeLoading = false
                            }
                            print("❌ 디테일 좋아요 서버통신 실패:", error)
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
                .buttonStyle(.plain)
                .disabled(isLikeLoading)
                .padding(.leading, 40)
                .padding(.top, 10)
                .padding(.trailing, 10)

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

                Button {
                    openSummary()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(Color("Gray1"))

                        Text("요약")
                            .font(.custom("Pretendard-Medium", size: 12))
                            .foregroundColor(Color("Gray1"))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color("White1"))
                            .overlay(
                                Capsule()
                                    .stroke(Color("Gray4"), lineWidth: 1)
                            )
                    )
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
                        guard post.id > 0 else { return }

                        commentErrorMessage = nil
                        let sending = trimmed
                        commentText = ""
                        isCommentFocused = false

                        Task {
                            do {
                                let created = try await commentService.create(postId: post.id, comment: sending)
                                await MainActor.run {
                                    comments.append(created)
                                    notifyCommentCountChanged()
                                }
                            } catch {
                                await MainActor.run {
                                    commentErrorMessage = "댓글 작성에 실패했어요.\n\(error.localizedDescription)"
                                }
                            }
                        }
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
            
            if isCommentsLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("댓글 불러오는 중...")
                        .font(.custom("Pretendard-Medium", size: 12))
                        .foregroundColor(Color("Gray3"))
                }
                .padding(.leading, 32)
                .padding(.top, 10)
            }

            if let commentErrorMessage {
                Text(commentErrorMessage)
                    .font(.custom("Pretendard-Medium", size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }

            if !comments.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(comments) { c in
                        HStack(alignment: .top, spacing: 12) {
                            Image("profiles 1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28, alignment: .top)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("익명")
                                    .font(.custom("Pretendard-Bold", size: 12))
                                    .foregroundColor(Color("Gray1"))

                                Text(c.comment)
                                    .font(.custom("Pretendard-Medium", size: 12))
                                    .foregroundColor(Color("Gray3"))
                            }

                            Spacer(minLength: 0)

                            Button {
                                Task {
                                    do {
                                        try await commentService.delete(commentId: c.commentId)
                                        await MainActor.run {
                                            comments.removeAll { $0.commentId == c.commentId }
                                            notifyCommentCountChanged()
                                        }
                                    } catch {
                                        await MainActor.run {
                                            commentErrorMessage = "댓글 삭제에 실패했어요.\n\(error.localizedDescription)"
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("Gray3"))
                                    .padding(8)
                            }
                            .buttonStyle(.plain)
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

            if isSummaryModalPresented {
                // Dim
                Color.black.opacity(0.45)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color("Blue1").opacity(0.15))
                                .frame(width: 34, height: 34)
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("Blue1"))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("재미나이 요약")
                                .font(.custom("Pretendard-Bold", size: 18))
                                .foregroundColor(Color("Gray1"))

                            Text("게시글 핵심만 뽑아드림")
                                .font(.custom("Pretendard-Medium", size: 12))
                                .foregroundColor(Color("Gray3"))
                        }

                        Spacer()

                        Button {
                            closeSummary()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color("Gray3"))
                                .padding(10)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)

                    // Body
                    VStack(alignment: .leading, spacing: 10) {
                        if let summaryErrorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color("Gray3"))

                                Text(summaryErrorMessage)
                                    .font(.custom("Pretendard-Medium", size: 12))
                                    .foregroundColor(Color("Gray3"))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("Gray4").opacity(0.18))
                            )
                        }

                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color("Gray4"), lineWidth: 1)
                            )
                            .overlay {
                                if isSummaryLoading {
                                    VStack(spacing: 10) {
                                        ProgressView()
                                        Text("요약 만드는 중...")
                                            .font(.custom("Pretendard-Medium", size: 12))
                                            .foregroundColor(Color("Gray3"))
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(16)
                                } else {
                                    ScrollView {
                                        Text(summaryText.isEmpty ? "요약 결과가 없어요." : summaryText)
                                            .font(.custom("Pretendard-Medium", size: 14))
                                            .foregroundColor(Color("Gray1"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(16)
                                    }
                                }
                            }
                            .frame(height: 190)

                        // Buttons
                        HStack(spacing: 10) {
                            Button {
                                openSummary()
                            } label: {
                                Text("다시 요약")
                                    .font(.custom("Pretendard-Bold", size: 14))
                                    .foregroundColor(Color("Gray1"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
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
                            .disabled(isSummaryLoading)
                            .opacity(isSummaryLoading ? 0.6 : 1)

                            Button {
                                copySummaryToClipboard()
                            } label: {
                                Text("복사")
                                    .font(.custom("Pretendard-Bold", size: 14))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color("Blue1"))
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(isSummaryLoading || summaryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .opacity((isSummaryLoading || summaryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.6 : 1)
                        }

                        Button {
                            closeSummary()
                        } label: {
                            Text("닫기")
                                .font(.custom("Pretendard-Bold", size: 14))
                                .foregroundColor(Color("Gray1"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
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
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 18)
                }
                .frame(maxWidth: 540)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
                )
                .padding(.horizontal, 22)
                .transition(.scale)
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
        .task {
       
            guard detail == nil else { return }
            print("🧩 BoardDetailView task postId=\(post.id)")
            guard post.id > 0 else { return }

            isDetailLoading = true
            detailErrorMessage = nil
            defer { isDetailLoading = false }

            do {
                print("API post 에러띠/\(post.id)")
                let res = try await postService.fetchPostDetail(postId: post.id)
                print("디테일 코드 에러러ㅓ=\(res.title) like=\(res.likeCount)")
                detail = res

                // ✅ 서버값이 와도, 이미 다른 화면에서 눌린 값(스토어)이 있으면 그걸 우선
                let storeCount = likeStore.likeCount(for: post.id, fallback: res.likeCount)
                let storeLiked = likeStore.isLiked(post.id)

                likeCount = storeCount

                if storeLiked {
                    // 스토어가 liked=true면 무조건 true
                    isLiked = true
                } else if let liked = extractIsLiked(from: res) {
                    // 스토어가 false면 서버가 제공하는 liked를 최대한 반영
                    isLiked = liked
                } else {
                    isLiked = false
                }

                // ✅ 최종값을 스토어에도 반영
                notifyLikeChanged()

                // ✅ 댓글 목록 로드
                isCommentsLoading = true
                commentErrorMessage = nil
                do {
                    let list = try await commentService.fetch(postId: post.id)
                    comments = list
                    notifyCommentCountChanged()
                } catch {
                    commentErrorMessage = "댓글을 불러오지 못했어요.\n\(error.localizedDescription)"
                }
                isCommentsLoading = false
            } catch {
                detailErrorMessage = "게시글을 불러오지 못했어요.\n\(error.localizedDescription)"
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isReportModalPresented)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("boardLikeChanged"))) { note in
            guard let info = note.userInfo else { return }
            guard let postId = info["postId"] as? Int else { return }
            guard postId == post.id else { return }

            let liked = (info["isLiked"] as? Bool) ?? (info["liked"] as? Bool) ?? false
            let count = (info["likeCount"] as? Int) ?? likeCount

            // ✅ 스토어 + 로컬 UI 동기화
            likeStore.apply(postId: postId, isLiked: liked, likeCount: count)
            isLiked = liked
            likeCount = count
        }
        .onDisappear {
            Task { @MainActor in
                notifyLikeChanged()
            }
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
        .onAppear {

        }
    }
}

}

#Preview {
    BoardDetailView(post: .sample)
}

