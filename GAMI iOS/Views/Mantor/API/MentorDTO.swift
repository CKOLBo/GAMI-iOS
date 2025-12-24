import Foundation

// MARK: - Mentor

/// /api/mentoring/mentor/all, /api/mentoring/random 응답용
struct MentorSummaryDTO: Decodable, Identifiable {
    let memberId: Int
    let name: String
    let gender: String
    let generation: Int
    let major: String

    var id: Int { memberId }
}

/// mentor/all이 페이지 형태로 내려오는 경우 대비 (content 또는 mentors)
struct MentorPageResponseDTO: Decodable {
    let content: [MentorSummaryDTO]?
    let mentors: [MentorSummaryDTO]?

    let totalElements: Int?
    let totalPages: Int?
    let number: Int?
    let size: Int?
}

// MARK: - Apply

/// 신청/목록 응답 공통
struct MentorApplyDTO: Decodable, Identifiable {
    let applyId: Int
    let menteeId: Int?
    let mentorId: Int?
    let name: String?
    let applyStatus: String
    let createdAt: String

    var id: Int { applyId }
}
