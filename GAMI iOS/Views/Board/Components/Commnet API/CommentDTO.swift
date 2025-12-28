//
//  CommentDTO.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation

struct CommentResponseDTO: Decodable, Identifiable {
    let postId: Int
    let commentId: Int
    let comment: String
    let createdAt: String

    var id: Int { commentId }
}

struct CreateCommentRequestDTO: Encodable {
    let comment: String
}
