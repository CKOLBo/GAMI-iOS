//
//  MentorService.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/23/25.
//

import Foundation

final class MentorService {

    /// 멘토 목록 조회 (페이징 + 필터)
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

        // 1) 혹시 배열로 바로 내려주는 경우
        if let arr: [MentorSummaryDTO] = try? await APIClient.shared.request(endpoint) {
            return arr
        }

        // 2) Page 형태로 내려주는 경우(content / mentors 둘 다 대응)
        let pageRes: MentorPageResponseDTO = try await APIClient.shared.request(endpoint)
        return pageRes.content ?? pageRes.mentors ?? []
    }

    /// 랜덤 멘토 추천
    func fetchRandomMentor() async throws -> MentorSummaryDTO {
        try await APIClient.shared.request(MentorEndpoint.fetchRandomMentor)
    }

    /// 멘토링 신청 (Swagger 기준 body 없음)
    func applyMentor(mentorId: Int) async throws -> MentorApplyDTO {
        try await APIClient.shared.request(MentorEndpoint.apply(mentorId: mentorId))
    }

    /// 내가 보낸 신청 목록
    func fetchSentApplies() async throws -> [MentorApplyDTO] {
        try await APIClient.shared.request(MentorEndpoint.fetchSentApplies)
    }

    /// 내가 받은 신청 목록
    func fetchReceivedApplies() async throws -> [MentorApplyDTO] {
        try await APIClient.shared.request(MentorEndpoint.fetchReceivedApplies)
    }

    /// 신청 상태 변경 (예: ACCEPTED / REJECTED)
    func patchApplyStatus(id: Int, applyStatus: String) async throws {
        try await APIClient.shared.requestNoBody(
            MentorEndpoint.patchApplyStatus(id: id, applyStatus: applyStatus)
        )
    }
}
