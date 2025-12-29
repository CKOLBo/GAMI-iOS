//
//  ChatEndPoint.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//
import Foundation

enum ChatEndpoint: Endpoint {
    case rooms
    case roomDetail(roomId: Int)
    case messages(roomId: Int, cursor: Int?)
    case leave(roomId: Int)

    var method: HTTPMethod {
        switch self {
        case .rooms, .roomDetail, .messages:
            return .get
        case .leave:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .rooms:
            return "/api/chat/rooms"
        case .roomDetail(let roomId):
            return "/api/chat/\(roomId)"
        case .messages(let roomId, _):
            return "/api/chat/\(roomId)/messages"
        case .leave(let roomId):
            return "/api/chat/rooms/\(roomId)/leave"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .messages(_, let cursor):
            guard let cursor else { return [] }
            return [URLQueryItem(name: "cursor", value: String(cursor))]
        default:
            return []
        }
    }

    var headers: [String: String] {
      
        let token = UserDefaults.standard.string(forKey: "accessToken") ?? ""
        guard !token.isEmpty else { return [:] }
        return ["Authorization": "Bearer \(token)"]
    }

    var body: Data? { nil }
}
