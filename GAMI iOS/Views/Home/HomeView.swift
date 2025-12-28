//
//  HomeView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/10/25.
//


extension Notification.Name {
    static let boardCommentCountChanged = Notification.Name("boardCommentCountChanged")
}

import SwiftUI

struct BoardPost: Identifiable {
    let id: Int
    let title: String
    let content: String
    let likeCount: Int
    let commentCount: Int
}

struct HomeProfileDTO: Decodable {
    let memberId: Int
    let name: String
    let gender: String
    let generation: Int
    let major: String
}

struct BoardPostDTO: Decodable {
    let id: Int
    let title: String
    let content: String
    let likeCount: Int
    let commentCount: Int
    let memberId: Int
    let createdAt: String
    let updatedAt: String
    let images: [String]
}

struct PostPageDTO: Decodable {
    let content: [BoardPostDTO]
    let totalElements: Int?
    let totalPages: Int?
    let number: Int?
    let size: Int?
    let last: Bool?
    let first: Bool?
    let empty: Bool?
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var profileName: String = ""
    @Published var profileGender: String = ""
    @Published var profileGenerationText: String = ""
    @Published var profileMajorText: String = ""

    @Published var posts: [BoardPost] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

 
    private let baseURL = "https://port-0-gami-server-mj0rdvda8d11523e.sel3.cloudtype.app"

    func load(accessToken: String) async {
        guard !accessToken.isEmpty else {
            self.errorMessage = "accessToken이 비어있습니다 (로그인 토큰 저장 확인 필요)"
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let p = fetchProfile(accessToken: accessToken)
            async let b = fetchBoardPosts(accessToken: accessToken)
            _ = try await (p, b)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    private func fetchProfile(accessToken: String) async throws {
      
        let url = URL(string: baseURL + "/api/member")!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "HomeProfile", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Profile HTTP \(http.statusCode)\n\(body)"])
        }

        let decoded = try JSONDecoder().decode(HomeProfileDTO.self, from: data)
        self.profileName = decoded.name
        self.profileGender = decoded.gender
        self.profileGenerationText = "\(decoded.generation)기"
        self.profileMajorText = decoded.major
    }

    private func fetchBoardPosts(accessToken: String) async throws {
  
        let url = URL(string: baseURL + "/api/post?page=0&size=10&sort=createdAt,desc")!
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "HomeBoard", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Board HTTP \(http.statusCode)\n\(body)"])
        }

        let decoded = try JSONDecoder().decode(PostPageDTO.self, from: data)
        self.posts = decoded.content.map { dto in
            BoardPost(
                id: dto.id,
                title: dto.title,
                content: dto.content,
                likeCount: dto.likeCount,
                commentCount: dto.commentCount
            )
        }
    }
}

struct HomeView: View {
    @Binding var selection: TabbarView.Tab

    @StateObject private var vm = HomeViewModel()

    private let postService = PostService()

    // ✅ 좋아요 서버통신 중 중복 탭 방지
    @State private var likeLoadingIDs: Set<Int> = []

    // ✅ 댓글 수 동기화 (Detail에서 변경되면 Home에서도 즉시 반영)
    // (중복 방지 로직이 필요해지면 여기서 Set으로 확장)


    // ✅ 앱 전역(공유) 좋아요 상태 저장소: 화면 재생성/탭 전환에도 유지
    @StateObject private var likeStore = BoardLikeStore.shared

    // ✅ NavigationLink로 감싸면 카드 내부 버튼(하트)이 안 눌릴 수 있어서, 선택 + destination 방식으로 이동
    @State private var selectedBoardPost: BoardPost? = nil
    @State private var isBoardDetailPresented: Bool = false

    var body: some View{
            ScrollView{
            VStack(alignment: .leading, spacing: 0){
                Text("홈")
                    .font(.custom( "Pretendard-Bold", size: 30)
                        )
                    .padding(.top,60)
                   
                if let err = vm.errorMessage {
                    Text(err)
                        .font(.custom("Pretendard-Medium", size: 12))
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(vm.profileName.isEmpty ? "-" : vm.profileName)
                        .font(.custom("Pretendard-Bold", size: 16))
                        .foregroundColor(Color("Gray3"))

                    HStack(spacing: 8) {
                        Text(vm.profileGender.isEmpty ? "-" : vm.profileGender)
                            .font(.custom("Pretendard-Bold", size: 10))
                            .foregroundColor(Color("Gray3"))

                        Rectangle()
                            .frame(width: 1, height: 14)
                            .foregroundColor(Color("Gray2"))

                        Text(vm.profileGenerationText.isEmpty ? "-" : vm.profileGenerationText)
                            .font(.custom("Pretendard-Bold", size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("Blue1"))
                            .cornerRadius(4)

                        Text(vm.profileMajorText.isEmpty ? "-" : vm.profileMajorText)
                            .font(.custom("Pretendard-Bold", size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("Purple1"))
                            .cornerRadius(4)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("White1"))
                .cornerRadius(12)
                .padding(.top, 3)
                
                WelcomeBar()
  
                Text("멘토찾기")
                    .font(.custom("Pretendard-Bold", size: 20))
                    .foregroundColor(Color("Gray1"))
                    .padding(.top, 28)
                
                
                Button {
                    selection = .mentor
                } label: {
                    MentorBar()
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
                
                Text("익명게시판")
                    .font(.custom("Pretendard-Bold", size: 20))
                    .foregroundColor(Color("Gray1"))
                    .padding(.top, 28)
                
                LazyVStack(spacing: 12) {
                    ForEach(vm.posts) { post in
                        let isLiked = likeStore.isLiked(post.id)
                        let displayLikeCount = likeStore.likeCount(for: post.id, fallback: post.likeCount)

                        BoardBar(
                            post: post,
                            isLiked: isLiked,
                            displayLikeCount: displayLikeCount,
                            onTapLike: {
                                // ✅ 서버통신 + Notification으로 전체 화면 동기화
                                guard !likeLoadingIDs.contains(post.id) else { return }
                                likeLoadingIDs.insert(post.id)

                                let currentlyLiked = likeStore.isLiked(post.id)
                                let nextLiked = !currentlyLiked
                                let nextCount = nextLiked
                                    ? (displayLikeCount + 1)
                                    : max(0, displayLikeCount - 1)

                                // Optimistic UI (공유 스토어)
                                likeStore.apply(postId: post.id, isLiked: nextLiked, likeCount: nextCount)

                                // ✅ 다른 화면(BoardHome/Detail)로 신호 쏘기
                                NotificationCenter.default.post(
                                    name: .boardLikeChanged,
                                    object: nil,
                                    userInfo: [
                                        "postId": post.id,
                                        "isLiked": nextLiked,
                                        "likeCount": nextCount
                                    ]
                                )

                                Task {
                                    defer {
                                        Task { @MainActor in
                                            likeLoadingIDs.remove(post.id)
                                        }
                                    }
                                    do {
                                        if nextLiked {
                                            try await postService.likePost(postId: post.id)
                                        } else {
                                            try await postService.unlikePost(postId: post.id)
                                        }
                                    } catch {
                                        // 실패면 롤백 + 알림
                                        let rollbackLiked = currentlyLiked
                                        let rollbackCount = displayLikeCount

                                        await MainActor.run {
                                            likeStore.apply(postId: post.id, isLiked: rollbackLiked, likeCount: rollbackCount)

                                            NotificationCenter.default.post(
                                                name: .boardLikeChanged,
                                                object: nil,
                                                userInfo: [
                                                    "postId": post.id,
                                                    "isLiked": rollbackLiked,
                                                    "likeCount": rollbackCount
                                                ]
                                            )
                                        }
                                        print("❌ HomeView like/unlike failed:", error)
                                    }
                                }
                            }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedBoardPost = post
                            isBoardDetailPresented = true
                        }
                    }
                }
                .padding(.top, 12)
                
            }
         
            
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.horizontal, 32)

            }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            let token = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            await vm.load(accessToken: token)
        }
        .onReceive(NotificationCenter.default.publisher(for: .boardLikeChanged)) { note in
            guard
                let info = note.userInfo,
                let postId = info["postId"] as? Int
            else { return }

            // ✅ 키 호환: isLiked(권장) / liked(기존)
            let liked = (info["isLiked"] as? Bool) ?? (info["liked"] as? Bool) ?? false
            let count = (info["likeCount"] as? Int) ?? 0

            // ✅ 공유 스토어 갱신 (Home/BoardHome/Detail 공통)
            likeStore.apply(postId: postId, isLiked: liked, likeCount: count)

            // ✅ HomeViewModel posts도 같이 갱신 (다른 화면 갔다 와도 유지)
            if let idx = vm.posts.firstIndex(where: { $0.id == postId }) {
                let p = vm.posts[idx]
                vm.posts[idx] = BoardPost(
                    id: p.id,
                    title: p.title,
                    content: p.content,
                    likeCount: count,
                    commentCount: p.commentCount
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .boardCommentCountChanged)) { note in
            guard
                let info = note.userInfo,
                let postId = info["postId"] as? Int,
                let commentCount = info["commentCount"] as? Int
            else { return }

            if let idx = vm.posts.firstIndex(where: { $0.id == postId }) {
                let p = vm.posts[idx]
                vm.posts[idx] = BoardPost(
                    id: p.id,
                    title: p.title,
                    content: p.content,
                    likeCount: p.likeCount,
                    commentCount: commentCount
                )
            }
        }
        .navigationDestination(isPresented: $isBoardDetailPresented) {
            if let p = selectedBoardPost {
                BoardDetailView(
                    post: BoardPostModel(
                        id: p.id,
                        title: p.title,
                        subtitle: p.content,
                        body: p.content,
                        likeCount: likeStore.likeCount(for: p.id, fallback: p.likeCount),
                        imageURLs: []
                    )
                )
            }
        }
    }
    func WelcomeBar() -> some View{
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color("Purple1"), Color("Blue1")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                        
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                .frame(width: 340, height: 80)
            
            Text("GAMI에 오신걸 환영합니다! 반가워요, \(vm.profileName.isEmpty ? "-" : vm.profileName)님")
                .padding(.vertical, 24)
                .padding(.leading, 24)
                .padding(.trailing, 134)
                .font(.custom("Pretendard-Bold", size: 16))
                .foregroundColor(.white)
            Image("party 1")
                .padding(.leading, 260)
        }
            .padding(.top, 24)
    }
    
    func MentorBar() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                .frame(maxWidth: .infinity, minHeight: 140)

            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Image("aa")
                        .resizable()
                        .frame(width: 84, height: 84)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("나에게 어울리는")
                            .foregroundColor(Color("Gray1"))

                        HStack(spacing: 0) {
                            Text("멘토")
                                .foregroundColor(Color("Blue1"))

                            Text("를 찾으러 가볼까요?")
                                .foregroundColor(Color("Gray1"))
                        }
                    }
                    .padding(.bottom, 16)
                }
                .font(.custom("Pretendard-Bold", size: 16))

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
    }
    
    func BoardBar(post: BoardPost, isLiked: Bool, displayLikeCount: Int, onTapLike: @escaping () -> Void) -> some View{
        ZStack(){
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 0){
                Text(post.title)
                    .font(.custom("Pretendard-Bold", size: 16))
                    .foregroundColor(Color("Gray1"))
                    .padding(.top, 20)
                    .padding(.leading, 16)

                HStack(spacing: 0){
                    Text("익명: ")
                        .font(.custom("Pretendard-Bold", size: 12))
                        .foregroundColor(Color("Gray1"))

                    Text(post.content)
                        .font(.custom("Pretendard-SemiBold", size: 10))
                        .foregroundColor(Color("Gray3"))
                        .lineLimit(1)
                }
                .padding(.top, 10)
                .padding(.leading, 16)

                HStack(spacing: 0) {
                    Button {
                        onTapLike()
                    } label: {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(isLiked ? .red : Color("Gray1"))
                            .padding(.leading, 16)
                            .padding(.top, 15)
                            .padding(.bottom, 15)
                    }
                    .buttonStyle(.plain)

                    Text("\(displayLikeCount)")
                        .font(.custom("Pretendard-Regular", size: 12))
                        .foregroundColor(Color("Gray1"))
                        .padding(.horizontal, 14)

                    Image("Text")

                    Text("\(post.commentCount)")
                        .font(.custom("Pretendard-Regular", size: 12))
                        .foregroundColor(Color("Gray1"))
                        .padding(.leading, 14)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        }
    }
    
}



#Preview {
    HomeView(selection: .constant(.home))
}


