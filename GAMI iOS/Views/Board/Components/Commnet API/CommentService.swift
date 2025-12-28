//
//  Untitled.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation

final class CommentService {
    private let client = APIClient.shared

    private struct EmptyResponseDTO: Decodable {}

    func fetchComments(postId: Int) async throws -> [CommentResponseDTO] {
        try await client.request(CommentAPI.fetchComments(postId: postId))
    }

    func createComment(postId: Int, comment: String) async throws -> CommentResponseDTO {
        let body = CreateCommentRequestDTO(comment: comment)
        return try await client.request(CommentAPI.createComment(postId: postId, body: body))
    }

    func deleteComment(commentId: Int) async throws {
        let _: EmptyResponseDTO = try await client.request(CommentAPI.deleteComment(commentId: commentId))
    }
}
