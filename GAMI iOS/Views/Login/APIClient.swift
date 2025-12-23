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



    private let baseURL = URL(string: "https://example.com")!

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

        // default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // custom headers
        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}

// MARK: - DTO

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}

struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String?
}

struct SendEmailCodeRequestDTO: Encodable {
    let email: String
}

struct VerifyEmailCodeRequestDTO: Encodable {
    let email: String
    let code: String
}

struct ResetPasswordRequestDTO: Encodable {
    let email: String
    let code: String
    let newPassword: String
}



enum AuthEndpoint: Endpoint {
    case login(LoginRequestDTO)
    case sendEmailCode(SendEmailCodeRequestDTO)
    case verifyEmailCode(VerifyEmailCodeRequestDTO)
    case resetPassword(ResetPasswordRequestDTO)

    var method: HTTPMethod {
        switch self {
        case .login, .sendEmailCode, .verifyEmailCode, .resetPassword:
            return .post
        }
    }


    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .sendEmailCode:
            return "/auth/email/send"
        case .verifyEmailCode:
            return "/auth/email/verify"
        case .resetPassword:
            return "/auth/password/reset"
        }
    }

    var body: Data? {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase

            switch self {
            case let .login(dto):
                return try encoder.encode(dto)
            case let .sendEmailCode(dto):
                return try encoder.encode(dto)
            case let .verifyEmailCode(dto):
                return try encoder.encode(dto)
            case let .resetPassword(dto):
                return try encoder.encode(dto)
            }
        } catch {
           
            return nil
        }
    }
}



final class AuthService {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func login(email: String, password: String) async throws -> LoginResponseDTO {
        let dto = LoginRequestDTO(email: email, password: password)

   
        let endpoint = AuthEndpoint.login(dto)
        guard endpoint.body != nil else { throw APIError.encoding(NSError(domain: "encoding", code: -1)) }

        return try await client.request(endpoint, as: LoginResponseDTO.self)
    }

    func sendEmailCode(email: String) async throws {
        let dto = SendEmailCodeRequestDTO(email: email)
        let endpoint = AuthEndpoint.sendEmailCode(dto)
        guard endpoint.body != nil else { throw APIError.encoding(NSError(domain: "encoding", code: -1)) }

        try await client.requestNoBody(endpoint)
    }

    func verifyEmailCode(email: String, code: String) async throws {
        let dto = VerifyEmailCodeRequestDTO(email: email, code: code)
        let endpoint = AuthEndpoint.verifyEmailCode(dto)
        guard endpoint.body != nil else { throw APIError.encoding(NSError(domain: "encoding", code: -1)) }

        try await client.requestNoBody(endpoint)
    }

    func resetPassword(email: String, code: String, newPassword: String) async throws {
        let dto = ResetPasswordRequestDTO(email: email, code: code, newPassword: newPassword)
        let endpoint = AuthEndpoint.resetPassword(dto)
        guard endpoint.body != nil else { throw APIError.encoding(NSError(domain: "encoding", code: -1)) }

        try await client.requestNoBody(endpoint)
    }
}
