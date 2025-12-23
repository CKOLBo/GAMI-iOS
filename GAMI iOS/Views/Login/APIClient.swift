//
//  AuthService + APIClient.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/23/25.
//

import Foundation



enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol Endpoint {
    var method: HTTPMethod { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

extension Endpoint {
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    var body: Data? { nil }
}

struct AnyEndpoint: Endpoint {
    let method: HTTPMethod
    let path: String
    let queryItems: [URLQueryItem]
    let headers: [String : String]
    let body: Data?

    init(
        method: HTTPMethod,
        path: String,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
}



enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int, Data?)
    case decoding(Error)
    case encoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL 입니다."
        case .invalidResponse:
            return "서버 응답이 올바르지 않습니다."
        case let .httpStatus(code, _):
            return "요청에 실패했습니다. (HTTP \(code))"
        case let .decoding(err):
            return "응답 디코딩 실패: \(err.localizedDescription)"
        case let .encoding(err):
            return "요청 인코딩 실패: \(err.localizedDescription)"
        }
    }
}



final class APIClient {
    static let shared = APIClient()


    private let baseURL: URL = {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           let url = URL(string: raw),
           !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return url
        }
        
        return URL(string: "https://example.com")!
    }()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type = T.self) async throws -> T {
        let request = try makeRequest(endpoint)
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode, data)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func requestNoBody(_ endpoint: Endpoint) async throws {
        let request = try makeRequest(endpoint)
        let (_, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode, nil)
        }
    }

    private func makeRequest(_ endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)
        components?.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

    
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

 
        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}



struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}

struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresIn: String
    let refreshTokenExpiresIn: String
}

struct SignUpRequestDTO: Encodable {
    let email: String
    let password: String
    let name: String
    let generation: Int
    let gender: String
    let major: String
}

struct SendVerificationCodeRequestDTO: Encodable {
    let email: String
    let verificationType: String
}

struct ReissueResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresIn: String
    let refreshTokenExpiresIn: String
}

struct ChangePasswordRequestDTO: Encodable {
    let email: String
    let newPassword: String
}



enum AuthEndpoint: Endpoint {
    case signup(SignUpRequestDTO)
    case signin(LoginRequestDTO)
    case sendVerificationCode(SendVerificationCodeRequestDTO)
    case verifyEmailCode(email: String, code: String)
    case reissue(refreshToken: String)
    case changePassword(ChangePasswordRequestDTO)
    case signout

    var method: HTTPMethod {
        switch self {
        case .signup, .signin, .sendVerificationCode, .verifyEmailCode:
            return .post
        case .reissue, .changePassword:
            return .patch
        case .signout:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .signup:
            return "/api/auth/signup"
        case .signin:
            return "/api/auth/signin"
        case .sendVerificationCode:
            return "/api/auth/email/send-code"
        case .verifyEmailCode:
            return "/api/auth/email/verification-code"
        case .reissue:
            return "/api/auth/reissue"
        case .changePassword:
            return "/api/auth/password"
        case .signout:
            return "/api/auth/signout"
        }
    }

    var headers: [String : String] {
        switch self {
        case let .reissue(refreshToken):
            return ["RefreshToken": refreshToken]
        default:
            return [:]
        }
    }

    var body: Data? {
        
        return nil
    }
}


final class AuthService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    private func encodeBody<T: Encodable>(_ dto: T) throws -> Data {
        let encoder = JSONEncoder()
       
        encoder.keyEncodingStrategy = .useDefaultKeys
        do {
            return try encoder.encode(dto)
        } catch {
            throw APIError.encoding(error)
        }
    }

    

    func signup(
        email: String,
        password: String,
        name: String,
        generation: Int,
        gender: String,
        major: String
    ) async throws {
        let dto = SignUpRequestDTO(
            email: email,
            password: password,
            name: name,
            generation: generation,
            gender: gender,
            major: major
        )

        let body = try encodeBody(dto)

        let endpoint = AnyEndpoint(
            method: AuthEndpoint.signup(dto).method,
            path: AuthEndpoint.signup(dto).path,
            headers: AuthEndpoint.signup(dto).headers,
            body: body
        )

        try await client.requestNoBody(endpoint)
    }

    func signin(email: String, password: String) async throws -> LoginResponseDTO {
        let dto = LoginRequestDTO(email: email, password: password)
        let body = try encodeBody(dto)

        let endpoint = AnyEndpoint(
            method: AuthEndpoint.signin(dto).method,
            path: AuthEndpoint.signin(dto).path,
            headers: AuthEndpoint.signin(dto).headers,
            body: body
        )

        return try await client.request(endpoint, as: LoginResponseDTO.self)
    }


    func sendVerificationCode(email: String, verificationType: String = "SIGN_UP") async throws {
        let dto = SendVerificationCodeRequestDTO(email: email, verificationType: verificationType)
        let body = try encodeBody(dto)

        let endpoint = AnyEndpoint(
            method: AuthEndpoint.sendVerificationCode(dto).method,
            path: AuthEndpoint.sendVerificationCode(dto).path,
            headers: AuthEndpoint.sendVerificationCode(dto).headers,
            body: body
        )

        try await client.requestNoBody(endpoint)
    }

    func verifyEmailCode(email: String, code: String) async throws {
        
        struct VerifyDTO: Encodable {
            let email: String
            let code: String
        }

        let dto = VerifyDTO(email: email, code: code)
        let body = try encodeBody(dto)

        let endpoint = AnyEndpoint(
            method: AuthEndpoint.verifyEmailCode(email: email, code: code).method,
            path: AuthEndpoint.verifyEmailCode(email: email, code: code).path,
            headers: AuthEndpoint.verifyEmailCode(email: email, code: code).headers,
            body: body
        )

        try await client.requestNoBody(endpoint)
    }

  

    func reissue(refreshToken: String) async throws -> ReissueResponseDTO {
        let endpoint = AnyEndpoint(
            method: AuthEndpoint.reissue(refreshToken: refreshToken).method,
            path: AuthEndpoint.reissue(refreshToken: refreshToken).path,
            headers: AuthEndpoint.reissue(refreshToken: refreshToken).headers,
            body: nil
        )

        return try await client.request(endpoint, as: ReissueResponseDTO.self)
    }



    func changePassword(email: String, newPassword: String) async throws {
        let dto = ChangePasswordRequestDTO(email: email, newPassword: newPassword)
        let body = try encodeBody(dto)

        let endpoint = AnyEndpoint(
            method: AuthEndpoint.changePassword(dto).method,
            path: AuthEndpoint.changePassword(dto).path,
            headers: AuthEndpoint.changePassword(dto).headers,
            body: body
        )

        try await client.requestNoBody(endpoint)
    }

    func signout() async throws {
        let endpoint = AnyEndpoint(
            method: AuthEndpoint.signout.method,
            path: AuthEndpoint.signout.path,
            headers: AuthEndpoint.signout.headers,
            body: nil
        )

        try await client.requestNoBody(endpoint)
    }
}
