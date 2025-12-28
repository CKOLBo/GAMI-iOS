
//
//  BoardLikeStore.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//

import Foundation
import SwiftUI


// MARK: - Shared Like State Store
@MainActor
final class BoardLikeStore: ObservableObject {
    static let shared = BoardLikeStore()

    @Published private(set) var likedPostIDs: Set<Int> = []
    @Published private(set) var likeCountOverride: [Int: Int] = [:]

    func isLiked(_ postId: Int) -> Bool {
        likedPostIDs.contains(postId)
    }

    func likeCount(for postId: Int, fallback: Int) -> Int {
        likeCountOverride[postId] ?? fallback
    }

    func apply(postId: Int, isLiked: Bool, likeCount: Int) {
        if isLiked {
            likedPostIDs.insert(postId)
        } else {
            likedPostIDs.remove(postId)
        }
        likeCountOverride[postId] = likeCount
    }
}
