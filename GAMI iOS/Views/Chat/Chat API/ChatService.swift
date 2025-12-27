//
//  ChatService.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation

final class ChatService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchRooms() async throws -> [ChatRoomDTO] {
        let ep = ChatEndpoint.rooms
        let endpoint = AnyEndpoint(method: ep.method, path: ep.path, queryItems: ep.queryItems, headers: ep.headers)
        return try await client.request(endpoint, as: [ChatRoomDTO].self)
    }

    func fetchRoomDetail(roomId: Int) async throws -> ChatRoomDetailDTO {
        let ep = ChatEndpoint.roomDetail(roomId: roomId)
        let endpoint = AnyEndpoint(method: ep.method, path: ep.path, queryItems: ep.queryItems, headers: ep.headers)
        return try await client.request(endpoint, as: ChatRoomDetailDTO.self)
    }

    func fetchMessages(roomId: Int, cursor: Int? = nil) async throws -> ChatMessagesResponseDTO {
        let ep = ChatEndpoint.messages(roomId: roomId, cursor: cursor)
        let endpoint = AnyEndpoint(method: ep.method, path: ep.path, queryItems: ep.queryItems, headers: ep.headers)
        return try await client.request(endpoint, as: ChatMessagesResponseDTO.self)
    }

    func leaveRoom(roomId: Int) async throws {
        let ep = ChatEndpoint.leave(roomId: roomId)
        let endpoint = AnyEndpoint(method: ep.method, path: ep.path, queryItems: ep.queryItems, headers: ep.headers)
        try await client.requestNoBody(endpoint)
    }
}
