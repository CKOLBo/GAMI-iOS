import Foundation

enum MentorEndpoint: Endpoint {
  
    case fetchMentorsAll(major: String?, name: String?, generation: Int?, page: Int, size: Int)

    
    case fetchRandomMentor

  
    case apply(mentorId: Int)


    case fetchSentApplies


    case fetchReceivedApplies


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

       
        if let saved = UserDefaults.standard.string(forKey: "accessToken") {
            let trimmed = saved.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                let token = trimmed.hasPrefix("Bearer ") ? String(trimmed.dropFirst("Bearer ".count)) : trimmed
                headers["Authorization"] = "Bearer \(token)"
            } else {
                #if DEBUG
                print("⚠️ accessToken is empty. Authorization header will be omitted.")
                #endif
            }
        } else {
            #if DEBUG
            print("⚠️ accessToken is nil. Authorization header will be omitted.")
            #endif
        }

        return headers
    }

    var body: Data? {
        switch self {
        case .patchApplyStatus(_, let applyStatus):
            let body: [String: Any] = ["applyStatus": applyStatus]
            return try? JSONSerialization.data(withJSONObject: body)
        default:
           
            return nil
        }
    }
}
