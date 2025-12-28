import Foundation

//
//  MemberDTO.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

// GET /api/member
struct MyProfileDTO: Decodable {
    let memberId: Int
    let name: String
    let gender: String
    let generation: Int
    let major: String
}

// PATCH /api/member/major
struct UpdateMajorRequestDTO: Encodable {
    let major: String
}

/// Used for endpoints that return no meaningful response body
struct EmptyResponse: Decodable {}
