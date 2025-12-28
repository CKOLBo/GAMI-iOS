//
//  PostDTO.swift.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation


struct PostListResponse: Decodable {
    let totalElements: Int
    let totalPages: Int
    let size: Int
    let content: [PostItemDTO]
    let number: Int
    let numberOfElements: Int
    let last: Bool
    let first: Bool
    let empty: Bool
}

struct PostItemDTO: Decodable, Identifiable, Hashable {
    let id: Int
    let title: String
    let content: String
    var likeCount: Int
    let commentCount: Int
    let memberId: Int
    let createdAt: String
    let updatedAt: String
    let images: [String]
}


typealias PostDetailDTO = PostItemDTO


struct PostImageDTO: Encodable {
    let imageUrl: String
    let sequence: Int
}

struct PostCreateRequest: Encodable {
    let title: String
    let content: String
    let images: [PostImageDTO]
}

typealias PostUpdateRequest = PostCreateRequest


struct PostSummaryResponse: Decodable {
    let postId: Int
    let summary: String
}

// MARK: - Board module aliases (used by BoardHomeView / BoardDetailView / PostService)

// List
typealias BoardPostItemDTO = PostItemDTO
typealias BoardPostListResponseDTO = PostListResponse

// Detail
typealias BoardPostDetailDTO = PostDetailDTO

// Create / Update
typealias PostImageUploadDTO = PostImageDTO
typealias PostCreateRequestDTO = PostCreateRequest
typealias PostUpdateRequestDTO = PostUpdateRequest

// Summary
typealias PostSummaryResponseDTO = PostSummaryResponse
