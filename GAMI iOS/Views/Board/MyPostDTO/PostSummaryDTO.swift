//
//  PostSummaryDTO.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation

struct PostSummaryResponseDTO: Decodable {
    let postId: Int
    let summary: String
}
