import Foundation

enum MentorEndpoint: Endpoint {
    /// 전공/이름/기수 조건으로 멘토 목록 조회 (페이징)
    case fetchMentorsAll(major: String?, name: String?, generation: Int?, page: Int, size: Int)

    /// 조건에 맞는 멘토 1명 랜덤 추천
    case fetchRandomMentor

    /// 특정 멘토에게 멘토링 신청 (body 없음)
    case apply(mentorId: Int)

    /// 내가 보낸 멘토링 신청 목록
    case fetchSentApplies

    /// 내가 받은 멘토링 신청 목록
    case fetchReceivedApplies

    /// 멘토링 신청 상태 변경
    case patchApplyStatus(id: Int, applyStatus: String)
}

extension MentorEndpoint {
    var method: HTTPMethod {
        switch self {
        case .fetchMentorsAll, .fetchRandomMentor, .fetchSentApplies, .fetchReceivedApplies:
            return .get
        case .apply:
            return .post
        case .patchApplyStatus:
            return .patch
        }
    }

    var path: String {
        switch self {
        case .fetchMentorsAll:
            return "/api/mentoring/mentor/all"
        case .fetchRandomMentor:
            return "/api/mentoring/random"
        case .apply(let mentorId):
            return "/api/mentoring/apply/\(mentorId)"
        case .fetchSentApplies:
            return "/api/mentoring/apply/sent"
        case .fetchReceivedApplies:
            return "/api/mentoring/apply/received"
        case .patchApplyStatus(let id, _):
            return "/api/mentoring/apply/\(id)"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .fetchMentorsAll(let major, let name, let generation, let page, let size):
            var items: [URLQueryItem] = [
                .init(name: "page", value: String(page)),
                .init(name: "size", value: String(size))
            ]
            if let major, !major.isEmpty { items.append(.init(name: "major", value: major)) }
            if let name, !name.isEmpty { items.append(.init(name: "name", value: name)) }
            if let generation { items.append(.init(name: "generation", value: String(generation))) }
            return items
        default:
            return []
        }
    }

    var headers: [String: String] {
        var headers: [String: String] = ["Content-Type": "application/json"]
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }

    var body: Data? {
        switch self {
        case .patchApplyStatus(_, let applyStatus):
            let body: [String: Any] = ["applyStatus": applyStatus]
            return try? JSONSerialization.data(withJSONObject: body)
        default:
            // apply(mentorId)는 Swagger 기준 body 없음
            return nil
        }
    }
}
