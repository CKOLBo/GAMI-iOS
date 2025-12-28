import Foundation


struct MentorSummaryDTO: Decodable, Identifiable {
    let memberId: Int
    let name: String
    let gender: String
    let generation: Int
    let major: String

    var id: Int { memberId }
}

struct MentorPageResponseDTO: Decodable {
    let content: [MentorSummaryDTO]?
    let mentors: [MentorSummaryDTO]?

    let totalElements: Int?
    let totalPages: Int?
    let number: Int?
    let size: Int?
}


struct MentorApplyDTO: Decodable, Identifiable {
    let applyId: Int
    let menteeId: Int?
    let mentorId: Int?
    let name: String?
    let applyStatus: String
    let createdAt: String

    var id: Int { applyId }
}
