//
//  MemberService.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation

final class MemberService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchMyProfile() async throws -> MyProfileDTO {
        try await client.request(MemberAPI.myProfile, as: MyProfileDTO.self)
    }

    func updateMajor(_ major: String) async throws {
        let endpoint = MemberAPI.updateMajor(major: major)
        try await client.requestNoBody(endpoint)
    }
}
