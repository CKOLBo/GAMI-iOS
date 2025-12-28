//
//  ChatDTO.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation


struct ChatRoomDTO: Decodable, Identifiable {
    let id: Int
    let name: String
    let lastMessage: String
    let major: String
    let generation: Int
}

struct ChatRoomDetailDTO: Decodable {
    let roomId: Int
    let name: String
    let major: String
    let generation: Int
}


struct ChatMessageItemDTO: Decodable, Identifiable {
    let messageId: Int
    let message: String
    let createdAt: String
    let senderId: Int
    let senderName: String

    var id: Int { messageId }
}

struct ChatMessagesResponseDTO: Decodable {
    let roomId: Int
    let messages: [ChatMessageItemDTO]
    let nextCursor: Int?
    let hasMore: Bool
    let roomStatus: String?
    let currentMemberLeft: Bool?
}
