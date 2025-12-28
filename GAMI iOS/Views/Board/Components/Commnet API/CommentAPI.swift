//
//  CommentAPI.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//
import Foundation

enum CommentAPI {
    case fetchComments(postId: Int)
    case createComment(postId: Int, body: CreateCommentRequestDTO)
    case deleteComment(commentId: Int)
}

extension CommentAPI: Endpoint {
    var method: HTTPMethod {
        switch self {
        case .fetchComments:
            return .get
        case .createComment:
            return .post
        case .deleteComment:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .fetchComments(let postId):
            return "/api/post/\(postId)/comment"
        case .createComment(let postId, _):
            return "/api/post/\(postId)/comment"
        case .deleteComment(let commentId):
            return "/api/post/comment/\(commentId)"
        }
    }

    var headers: [String : String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "accessToken") ?? "")"
        ]
    }

    var body: Data? {
        switch self {
        case .createComment(_, let body):
            return try? JSONEncoder().encode(body)
        default:
            return nil
        }
    }
}
