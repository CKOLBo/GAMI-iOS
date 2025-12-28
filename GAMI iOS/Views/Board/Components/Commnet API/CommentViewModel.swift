//
//  CommentViewModel.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation

@MainActor
final class CommentViewModel: ObservableObject {
    @Published var comments: [CommentResponseDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let service = CommentService()

    func loadComments(postId: Int) {
        guard postId > 0 else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let list = try await service.fetchComments(postId: postId)
                self.comments = list
            } catch {
                self.errorMessage = "댓글을 불러오지 못했어요.\n\(error.localizedDescription)"
                print("❌ 댓글 조회 실패:", error)
            }
            self.isLoading = false
        }
    }

    func addComment(postId: Int, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard postId > 0, !trimmed.isEmpty else { return }
        errorMessage = nil

        Task {
            do {
                let created = try await service.createComment(postId: postId, comment: trimmed)
                self.comments.append(created) // optimistic update
            } catch {
                self.errorMessage = "댓글 작성에 실패했어요.\n\(error.localizedDescription)"
                print("❌ 댓글 작성 실패:", error)
            }
        }
    }

    func removeComment(commentId: Int) {
        guard commentId > 0 else { return }
        errorMessage = nil

        Task {
            do {
                try await service.deleteComment(commentId: commentId)
                self.comments.removeAll { $0.commentId == commentId }
            } catch {
                self.errorMessage = "댓글 삭제에 실패했어요.\n\(error.localizedDescription)"
                print("❌ 댓글 삭제 실패:", error)
            }
        }
    }
}
