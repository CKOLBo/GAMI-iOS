//
//  MemberAPI.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation

enum MemberAPI {
    case myProfile
    case updateMajor(major: String)
}

extension MemberAPI: Endpoint {
    var method: HTTPMethod {
        switch self {
        case .myProfile: return .get
        case .updateMajor: return .patch
        }
    }

    var path: String {
        switch self {
        case .myProfile:
            return "/api/member"
        case .updateMajor:
            return "/api/member/major"
        }
    }

    var body: Data? {
        switch self {
        case .updateMajor(let major):
            return try? JSONEncoder().encode(UpdateMajorRequestDTO(major: major))
        default:
            return nil
        }
    }
}
