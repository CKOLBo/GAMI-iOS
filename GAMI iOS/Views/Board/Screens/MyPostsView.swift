//
//  MyPostsView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//

import SwiftUI

struct MyPost: Identifiable, Codable {
    let id: String
    let title: String
    let body: String
    let imagePaths: [String]
    let createdAt: Double
}


struct MyPostsView: View {

    @Binding var path: NavigationPath

    @State private var searchText: String = ""
    @State private var isWritingPresented: Bool = false
    @Environment(\.dismiss) private var dismiss

    @State private var myPosts: [MyPost] = []
    @State private var isDeleteModalPresented: Bool = false
    @State private var deleteTargetPostID: String? = nil

    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                
                Button {
                    if path.count > 0 {
                        path.removeLast(path.count) // pop to root (HomeView)
                    } else {
                        dismiss() // fallback
                    }
                } label: {
                    HStack(spacing: 0) {
                        Image("Back")
                            .padding(.trailing, 8)
                        Text("돌아가기")
                            .font(.custom("Pretendard-Medium", size: 16))
                            .foregroundColor(Color("Gray3"))
                    }
                }
                
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
                .padding(.top, 16)

                
                Text("내가 쓴 글")
                    .font(.custom("Pretendard-Bold", size: 32))
                    .foregroundColor(Color.black)
                    .padding(.top, 16)
                    .padding(.leading, 32)
                
                myPostSearch(searchText: $searchText)
                    .padding(.top, 50)
                    .padding(.horizontal, 31)
                
                ForEach(myPosts.filter { post in
                    let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if q.isEmpty { return true }
                    return post.title.localizedCaseInsensitiveContains(q) || post.body.localizedCaseInsensitiveContains(q)
                }) { p in
                    NavigationLink {
                        BoardDetailView()
                    } label: {
                        MyPostRowCard(
                            title: p.title,
                            preview: p.body,
                            likeCount: 0,
                            commentCount: 0,
                            thumbnail: nil,
                            onTapDelete: {
                                deleteTargetPostID = p.id
                                isDeleteModalPresented = true
                            }
                        )
                    }
                    .padding(.horizontal, 31)
                    .padding(.top, 32)
                    .buttonStyle(.plain)
                }
                
            }
            }

            MyPostsFloatingPlusButton {
                isWritingPresented = true
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            if isDeleteModalPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                DeletePostModalView(
                    onCancel: {
                        isDeleteModalPresented = false
                        deleteTargetPostID = nil
                    },
                    onDelete: {
                        if let id = deleteTargetPostID {
                            deletePost(id: id)
                        }
                        isDeleteModalPresented = false
                        deleteTargetPostID = nil
                    }
                )
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .transition(.scale)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isWritingPresented) {
            BoardwritingView()
        }
        .onAppear {
            loadMyPosts()
        }
        .onReceive(NotificationCenter.default.publisher(for: .boardPostCreated)) { _ in
            loadMyPosts()
        }
        
    }

    private func loadMyPosts() {
        let defaults = UserDefaults.standard
        let key = "local_my_posts"

        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([MyPost].self, from: data) else {
            myPosts = []
            return
        }

        myPosts = decoded.sorted { $0.createdAt > $1.createdAt }
    }

    private func deletePost(id: String) {
        let defaults = UserDefaults.standard
        let keys = ["local_my_posts", "local_board_posts"]

        for key in keys {
            guard let data = defaults.data(forKey: key),
                  var decoded = try? JSONDecoder().decode([MyPost].self, from: data) else {
                continue
            }

            decoded.removeAll { $0.id == id }

            if let encoded = try? JSONEncoder().encode(decoded) {
                defaults.set(encoded, forKey: key)
            }
        }

        loadMyPosts()
    }
}

private struct MyPostRowCard: View {
    let title: String
    let preview: String
    let likeCount: Int
    let commentCount: Int
    let thumbnail: Image?
    let onTapDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.custom("Pretendard-Bold", size: 16))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text("익명 · \(preview)")
                    .font(.custom("Pretendard-Medium", size: 12))
                    .foregroundColor(Color("Gray3"))
                    .lineLimit(1)
                    .padding(.top, 6)

                HStack(spacing: 0) {
                    Image("Hart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 12)

                    Text("\(likeCount)")
                        .font(.custom("Pretendard-Medium", size: 12))
                        .foregroundColor(Color("Gray3"))
                        .padding(.leading, 6)

                    Image("Text")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .padding(.leading, 14)

                    Text("\(commentCount)")
                        .font(.custom("Pretendard-Medium", size: 12))
                        .foregroundColor(Color("Gray3"))
                        .padding(.leading, 6)

                    Button {
                        onTapDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color("Gray3"))
                            .padding(.leading, 14)
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 0)
                }
                .padding(.top, 12)
            }

            Spacer(minLength: 12)

            if let thumbnail {
                thumbnail
                    .resizable()
                    .scaledToFill()
                    .frame(width: 86, height: 86)
                    .clipped()
                    .cornerRadius(14)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("White1"))
        )
    }
}

private struct DeletePostModalView: View {
    let onCancel: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("게시글 삭제하기")
                .font(.custom("Pretendard-Bold", size: 20))
                .foregroundColor(Color("Gray1"))
            
                .padding(.bottom, 60)

            VStack(alignment: .leading, spacing: 0) {
                Text("정말 삭제하시겠어요?")
                    .font(.custom("Pretendard-SemiBold", size: 12))
                    .foregroundColor(Color("Gray1"))

                Text("삭제하기를 누를 시 복구 되지 않아요.")
                    .font(.custom("Pretendard-SemiBold", size: 12))
                    .foregroundColor(Color("Gray3"))
                    .padding(.bottom, 56)
                    
            }
            .padding(.top, 28)

            HStack(spacing: 16) {
                Button {
                    onCancel()
                } label: {
                    Text("취소")
                        .font(.custom("Pretendard-Bold", size: 16))
                        .foregroundColor(Color("Gray1"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color("Gray3"), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    onDelete()
                } label: {
                    Text("삭제하기")
                        .font(.custom("Pretendard-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.red.opacity(0.75))
                        .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 32)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
        )
    }
}

private struct MyPostsFloatingPlusButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color("Blue1"))
                    .frame(width: 62, height: 62)
                Image("plus")
                    
                    

            }
            .padding(.bottom, 20)
            .frame(maxHeight: .infinity, alignment: .bottom)
        
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()

    NavigationStack(path: $path) {
        MyPostsView(path: $path)
    }
}
