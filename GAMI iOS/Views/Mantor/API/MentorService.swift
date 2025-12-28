//
//  MentorService.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/23/25.
//

import Foundation

final class MentorService {

    
    func fetchMentorsAll(
        major: String? = nil,
        name: String? = nil,
        generation: Int? = nil,
        page: Int = 0,
        size: Int = 10
    ) async throws -> [MentorSummaryDTO] {

        let endpoint = MentorEndpoint.fetchMentorsAll(
            major: major,
            name: name,
            generation: generation,
            page: page,
            size: size
        )

    
        if let arr: [MentorSummaryDTO] = try? await APIClient.shared.request(endpoint) {
            return arr
        }

       
        let pageRes: MentorPageResponseDTO = try await APIClient.shared.request(endpoint)
        return pageRes.content ?? pageRes.mentors ?? []
    }

    
    func fetchRandomMentor() async throws -> MentorSummaryDTO {
        try await APIClient.shared.request(MentorEndpoint.fetchRandomMentor)
    }

    
    func applyMentor(mentorId: Int) async throws -> MentorApplyDTO {
        try await APIClient.shared.request(MentorEndpoint.apply(mentorId: mentorId))
    }

  
    func fetchSentApplies() async throws -> [MentorApplyDTO] {
        try await APIClient.shared.request(MentorEndpoint.fetchSentApplies)
    }


    func fetchReceivedApplies() async throws -> [MentorApplyDTO] {
        try await APIClient.shared.request(MentorEndpoint.fetchReceivedApplies)
    }

   
    func patchApplyStatus(id: Int, applyStatus: String) async throws {
        try await APIClient.shared.requestNoBody(
            MentorEndpoint.patchApplyStatus(id: id, applyStatus: applyStatus)
        )
    }
}
