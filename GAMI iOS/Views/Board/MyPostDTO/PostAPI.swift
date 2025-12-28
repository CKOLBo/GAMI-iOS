//
//  PostAPI.swift.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation

enum PostAPI {

  
    struct List: Endpoint {
        let keyword: String?
        let page: Int
        let size: Int
        let sort: String

        var method: HTTPMethod { .get }
        var path: String { "/api/post" }

        var queryItems: [URLQueryItem] {
            var items: [URLQueryItem] = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size)),
                URLQueryItem(name: "sort", value: sort)
            ]
            if let keyword, !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                items.append(URLQueryItem(name: "keyword", value: keyword))
            }
            return items
        }
    }

    
    struct Create: Endpoint {
        let bodyDTO: PostCreateRequestDTO

        var method: HTTPMethod { .post }
        var path: String { "/api/post" }

        var headers: [String : String] {
            ["Content-Type": "application/json"]
        }

        var body: Data? {
            try? JSONEncoder().encode(bodyDTO)
        }
    }

 
    struct Detail: Endpoint {
        let postId: Int

        var method: HTTPMethod { .get }
        var path: String { "/api/post/\(postId)" }
    }

    struct Delete: Endpoint {
        let postId: Int

        var method: HTTPMethod { .delete }
        var path: String { "/api/post/\(postId)" }
    }


    struct Update: Endpoint {
        let postId: Int
        let bodyDTO: PostUpdateRequestDTO

        var method: HTTPMethod { .patch }
        var path: String { "/api/post/\(postId)" }

        var headers: [String : String] {
            ["Content-Type": "application/json"]
        }

        var body: Data? {
            try? JSONEncoder().encode(bodyDTO)
        }
    }

   
    struct Summary: Endpoint {
        let postId: Int

        var method: HTTPMethod { .get }
        var path: String { "/api/post/summary/\(postId)" }
    }

    // MARK: - Like

    struct Like: Endpoint {
        let postId: Int

        var method: HTTPMethod { .post }
        var path: String { "/api/post/\(postId)/like" }
    }

    struct Unlike: Endpoint {
        let postId: Int

        var method: HTTPMethod { .delete }
        var path: String { "/api/post/\(postId)/like" }
    }
}
