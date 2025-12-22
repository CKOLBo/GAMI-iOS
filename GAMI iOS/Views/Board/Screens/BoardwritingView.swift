//
//  BoardwritingView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//

import SwiftUI
import PhotosUI

struct BoardwritingView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var titleText: String = ""
    @State private var bodyText: String = ""

    @State private var pickedItems: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []

    @State private var isSubmitting: Bool = false
    @State private var showSubmitAlert: Bool = false
    @State private var submitAlertMessage: String = ""

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image("Back")
                                Text("돌아가기")
                                    .font(.custom("Pretendard-Medium", size: 16))
                                    .foregroundColor(Color("Gray3"))
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 12)
                        .padding(.top, 16)

                        Text("익명 게시판")
                            .font(.custom("Pretendard-Bold", size: 32))
                            .foregroundColor(.black)
                            .padding(.leading, 32)
                            .padding(.top, 16)

                        VStack(alignment: .leading, spacing: 0) {
                            ZStack(alignment: .leading) {
                                if titleText.isEmpty {
                                    Text("제목을 입력해주세요")
                                        .font(.custom("Pretendard-SemiBold", size: 24))
                                        .foregroundColor(Color("Gray3"))
                                }
                                TextField("", text: $titleText)
                                    .font(.custom("Pretendard-SemiBold", size: 24))
                                    .foregroundColor(.black)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                            }
                            .padding(.horizontal, 32)
                            .padding(.top, 40)

                            Rectangle()
                                .fill(Color("Gray2"))
                                .frame(height: 1)
                                .padding(.horizontal, 16)
                                .padding(.top, 12)

                            ZStack(alignment: .topLeading) {
                                if bodyText.isEmpty {
                                    Text("내용을 입력 해주세요")
                                        .font(.custom("Pretendard-Regular", size: 16))
                                        .foregroundColor(Color("Gray3"))
                                        .padding(.top, 12)
                                        .padding(.leading, 4)
                                }

                                TextEditor(text: $bodyText)
                                    .font(.custom("Pretendard-Regular", size: 16))
                                    .foregroundColor(.black)
                                    .frame(minHeight: 260)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                            }
                            .padding(.horizontal, 32)
                            .padding(.top, 14)

                            Rectangle()
                                .fill(Color("Gray2"))
                                .frame(height: 1)
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                        }

                        VStack(alignment: .leading, spacing: 0) {
                            LazyVGrid(columns: columns, spacing: 12) {
                                PhotosPicker(
                                    selection: $pickedItems,
                                    maxSelectionCount: 9,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color("White1"))

                                        Image("Camara")
                                
                                    }
                                    .aspectRatio(1, contentMode: .fit)
                                }
                                .buttonStyle(.plain)

                                ForEach(images.indices, id: \.self) { idx in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: images[idx])
                                            .resizable()
                                            .scaledToFill()
                                            .aspectRatio(1, contentMode: .fit)
                                            .clipped()
                                            .cornerRadius(14)

                                        Button {
                                            removeImage(at: idx)
                                        } label: {
                                            Image("Camara")
                                                .shadow(radius: 2)
                                                .padding(6)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 18)
                            .padding(.bottom, 20)
                        }
                    }
                }

                Button {
                    Task { await submitPost() }
                } label: {
                    Text(isSubmitting ? "등록 중..." : "등록하기")
                        .font(.custom("Pretendard-SemiBold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color("Blue1"))
                        .cornerRadius(14)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
                .buttonStyle(.plain)
                .disabled(isSubmitting || titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity((isSubmitting || titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1)
            }
        }
        .onChange(of: pickedItems) { _, newItems in
            Task {
                await loadImages(from: newItems)
            }
        }
        .alert("알림", isPresented: $showSubmitAlert) {
            Button("확인") {
                if submitAlertMessage == "등록되었습니다" {
                    dismiss()
                }
            }
        } message: {
            Text(submitAlertMessage)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func removeImage(at index: Int) {
        guard images.indices.contains(index) else { return }
        images.remove(at: index)

        if pickedItems.indices.contains(index) {
            pickedItems.remove(at: index)
        }
    }

    private func submitValidation() -> Bool {
        if titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            submitAlertMessage = "제목을 입력해주세요"
            showSubmitAlert = true
            return false
        }
        if bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            submitAlertMessage = "내용을 입력해주세요"
            showSubmitAlert = true
            return false
        }
        return true
    }

    private func saveImagesToDisk() async throws -> [String] {
        guard !images.isEmpty else { return [] }

        let fm = FileManager.default
        let base = try fm.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("BoardUploads", isDirectory: true)

        if !fm.fileExists(atPath: base.path) {
            try fm.createDirectory(at: base, withIntermediateDirectories: true)
        }

        var paths: [String] = []
        for (i, img) in images.enumerated() {
            guard let data = img.jpegData(compressionQuality: 0.9) else { continue }
            let fileURL = base.appendingPathComponent("\(UUID().uuidString)_\(i).jpg")
            try data.write(to: fileURL)
            paths.append(fileURL.path)
        }
        return paths
    }

    private func savePostLocally(title: String, body: String, imagePaths: [String]) throws {
        struct LocalPost: Codable {
            let id: String
            let title: String
            let body: String
            let imagePaths: [String]
            let createdAt: Double
        }

        let post = LocalPost(
            id: UUID().uuidString,
            title: title,
            body: body,
            imagePaths: imagePaths,
            createdAt: Date().timeIntervalSince1970
        )

        let defaults = UserDefaults.standard
        let keys = ["local_board_posts", "local_my_posts"]

        for key in keys {
            var current: [LocalPost] = []
            if let data = defaults.data(forKey: key),
               let decoded = try? JSONDecoder().decode([LocalPost].self, from: data) {
                current = decoded
            }

            current.insert(post, at: 0)
            let encoded = try JSONEncoder().encode(current)
            defaults.set(encoded, forKey: key)
        }

        NotificationCenter.default.post(
            name: .boardPostCreated,
            object: nil,
            userInfo: [
                "id": post.id,
                "title": post.title,
                "body": post.body,
                "imagePaths": post.imagePaths,
                "createdAt": post.createdAt
            ]
        )
    }

    private func submitPost() async {
        guard submitValidation() else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let paths = try await saveImagesToDisk()
            try savePostLocally(
                title: titleText.trimmingCharacters(in: .whitespacesAndNewlines),
                body: bodyText.trimmingCharacters(in: .whitespacesAndNewlines),
                imagePaths: paths
            )

            submitAlertMessage = "등록되었습니다"
            showSubmitAlert = true
        } catch {
            submitAlertMessage = "등록에 실패했습니다"
            showSubmitAlert = true
        }
    }

    private func loadImages(from items: [PhotosPickerItem]) async {
        var newImages: [UIImage] = []

        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                newImages.append(uiImage)
            }
        }

        images = newImages
    }
}

extension Notification.Name {
    static let boardPostCreated = Notification.Name("boardPostCreated")
}

#Preview {
    BoardwritingView()
}
