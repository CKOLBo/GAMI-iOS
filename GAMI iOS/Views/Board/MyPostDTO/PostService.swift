//
//  PostService.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation

final class PostService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchPostList(
        keyword: String? = nil,
        page: Int = 0,
        size: Int = 10,
        sort: String = "createdAt,desc"
    ) async throws -> BoardPostListResponseDTO {
        let endpoint = PostAPI.List(keyword: keyword, page: page, size: size, sort: sort)
        return try await client.request(endpoint, as: BoardPostListResponseDTO.self)
    }

    func fetchPostDetail(postId: Int) async throws -> BoardPostDetailDTO {
        let endpoint = PostAPI.Detail(postId: postId)
        return try await client.request(endpoint, as: BoardPostDetailDTO.self)
    }

    func likePost(postId: Int) async throws {
        let endpoint = PostAPI.Like(postId: postId)
        try await client.requestNoBody(endpoint)
    }

    func unlikePost(postId: Int) async throws {
        let endpoint = PostAPI.Unlike(postId: postId)
        try await client.requestNoBody(endpoint)
    }

    func createPost(
        title: String,
        content: String,
        images: [PostImageUploadDTO] = []
    ) async throws -> Int {
        let dto = PostCreateRequestDTO(title: title, content: content, images: images)
        let endpoint = PostAPI.Create(bodyDTO: dto)
        return try await client.request(endpoint, as: Int.self)
    }

    func updatePost(
        postId: Int,
        title: String,
        content: String,
        images: [PostImageUploadDTO] = []
    ) async throws {
        let dto = PostUpdateRequestDTO(title: title, content: content, images: images)
        let endpoint = PostAPI.Update(postId: postId, bodyDTO: dto)
        try await client.requestNoBody(endpoint)
    }

    func deletePost(postId: Int) async throws {
        let endpoint = PostAPI.Delete(postId: postId)
        try await client.requestNoBody(endpoint)
    }

    // ✅ 게시글 요약 조회
    func fetchPostSummary(postId: Int) async throws -> PostSummaryResponseDTO {
        let endpoint = PostAPI.Summary(postId: postId)
        return try await client.request(endpoint, as: PostSummaryResponseDTO.self)
    }
}
