//
//  ChatView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/21/25.
//

import SwiftUI

struct ChatItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let lastMessage: String
    let major: String
    let generation: Int
}


private struct MentorRequestModal: View {
    @Binding var isPresented: Bool
    @Binding var items: [MentorApplyDTO]
    let onAccept: (MentorApplyDTO) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("멘토 신청 목록")
                        .font(.custom("Pretendard-SemiBold", size: 20))
                        .foregroundColor(Color("Gray1"))

                    Text("신청 된 멘토를 확인 해주세요.")
                        .font(.custom("Pretendard-Semi.Bold", size: 12))
                        .foregroundColor(Color("Gray3"))
                        .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 22)
                .padding(.horizontal, 22)
                .padding(.bottom, 14)

                Rectangle()
                    .fill(Color("Gray2"))
                    .frame(height: 1)
                    .opacity(0.35)
                    .padding(.horizontal, 22)

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(items) { item in
                            HStack(spacing: 0) {
                                Image("profiles 1")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 24, height: 24)
                                    .padding(.trailing, 10)

                                Text("\((item.name ?? "알 수 없음")) 님께 요청이 왔어요.")
                                    .font(.custom("Pretendard-SemiBold", size: 10))
                                    .foregroundColor(Color("Gray3"))
                                    .lineLimit(1)

                                Spacer(minLength: 0)

                                Button {
                                    Task {
                                        do {
                                            let service = MentorService()
                                            try await service.patchApplyStatus(id: item.applyId, applyStatus: "ACCEPTED")
                                            await MainActor.run {
                                                onAccept(item)
                                                withAnimation(.easeInOut(duration: 0.15)) {
                                                    items.removeAll { $0.applyId == item.applyId }
                                                }
                                            }
                                        } catch {
                                            print(error)
                                        }
                                    }
                                } label: {
                                    Text("수락")
                                        .font(.custom("Pretendard-Bold", size: 10))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .frame(height: 28)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color("Blue1"))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("White1"))
                            )
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 12)
                }
                .scrollIndicators(.hidden)

                Spacer(minLength: 0)
            }
            .frame(width: 332, height: 560)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
            )
        }
    }
}

struct ChatView: View {

    enum Tab {
        case chat
        case request
    }

    @State private var selectedTab: Tab = .chat
    @State private var searchText: String = ""
    @State private var sentApplies: [MentorApplyDTO] = []
    @State private var cancellingApplyId: Int? = nil
    @State private var isMentorModalPresented: Bool = false
    @State private var mentorRequests: [MentorApplyDTO] = []
    @State private var selectedChat: ChatItem? = nil

    @State private var chats: [ChatItem] = []

    private let mentorService = MentorService()
    private let chatService = ChatService()

    private var filteredChats: [ChatItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return chats }
        return chats.filter {
            $0.name.localizedCaseInsensitiveContains(q) ||
            $0.lastMessage.localizedCaseInsensitiveContains(q)
        }
    }
    @MainActor
    private func handleAccept(_ item: MentorApplyDTO) {
        let rawName = (item.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let chatName = rawName.isEmpty ? "멘티" : rawName
        if chats.contains(where: { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) == chatName }) {
            if let idx = chats.firstIndex(where: { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) == chatName }) {
                let existing = chats.remove(at: idx)
                chats.insert(existing, at: 0)
            }
            selectedTab = .chat
            searchText = ""
            return
        }
        chats.insert(
            ChatItem(id: -Int(item.applyId), name: chatName, lastMessage: "멘토링이 시작되었어요.", major: "", generation: 0),
            at: 0
        )
        selectedTab = .chat
        searchText = ""
    }

    private var filteredRequests: [MentorApplyDTO] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = sentApplies
        if q.isEmpty { return base }
        return base.filter { ($0.name ?? "").localizedCaseInsensitiveContains(q) }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func onTabChanged(_ newValue: Tab) {
        if newValue == .request {
            loadSentApplies()
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("채팅")
                            .font(.custom("Pretendard-Bold", size: selectedTab == .chat ? 32 : 24))
                            .foregroundColor(selectedTab == .chat ? Color("Gray1") : Color("Gray2"))
                            .padding(.trailing, 12)
                            .padding(.leading, 32)
                            .contentShape(Rectangle())
                            .onTapGesture { selectedTab = .chat }

                        Rectangle()
                            .frame(width: 2, height: 32)
                            .foregroundColor(Color("Gray1"))
                            .cornerRadius(12)

                        Text("요청")
                            .font(.custom("Pretendard-Bold", size: selectedTab == .request ? 32 : 24))
                            .foregroundColor(selectedTab == .request ? Color("Gray1") : Color("Gray2"))
                            .padding(.leading, 12)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTab = .request
                                loadSentApplies()
                            }

                        Spacer()

                        Image("Alarm")
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isMentorModalPresented = true
                                Task {
                                    do {
                                        let res = try await mentorService.fetchReceivedApplies()
                                        await MainActor.run {
                                            mentorRequests = res.filter { $0.applyStatus.uppercased() == "PENDING" }
                                        }
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                            .padding(.trailing, 31)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 43)

                    ZStack(alignment: .leading) {
                        Image("searchBar")

                        HStack {
                            Image("search")
                                .padding(.leading, 21)

                            TextField(
                                "멘토 또는 멘티 검색",
                                text: $searchText,
                                prompt: Text("멘토 또는 멘티 검색")
                                    .font(.custom("Pretendard-Bold", size: 12))
                                    .foregroundColor(Color("Gray3"))
                            )
                            .font(.custom("Pretendard-Bold", size: 12))
                            .frame(width: 250)
                            .foregroundColor(Color("Gray3"))
                        }
                    }
                    .padding(.bottom, 22)

                    if selectedTab == .request {
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(filteredRequests) { item in
                                    HStack(spacing: 0) {
                                        Image("profiles 1")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 32, height: 32)
                                            .padding(.leading, 12)

                                        Text("\((item.name ?? "알 수 없음")) 님한테 요청을 보냈어요.")
                                            .font(.custom("Pretendard-SemiBold", size: 14))
                                            .foregroundColor(Color("Gray3"))
                                            .lineLimit(1)
                                            .padding(.leading, 12)

                                        Spacer(minLength: 0)

                                        Button {
                                            guard cancellingApplyId == nil else { return }
                                            cancellingApplyId = Int(item.applyId)
                                            print("➡️ PATCH /api/mentoring/apply/\(item.applyId) CANCELLED")

                                            Task {
                                                do {
                                                    try await mentorService.patchApplyStatus(id: item.applyId, applyStatus: "CANCELLED")
                                                    await MainActor.run {
                                                        withAnimation(.easeInOut(duration: 0.15)) {
                                                            sentApplies.removeAll { $0.applyId == item.applyId }
                                                        }
                                                        cancellingApplyId = nil
                                                    }
                                                    loadSentApplies()
                                                } catch {
                                                    await MainActor.run {
                                                        cancellingApplyId = nil
                                                    }
                                                    print("요청 취소 실패:", error)
                                                }
                                            }
                                        } label: {
                                            Text(cancellingApplyId == Int(item.applyId) ? "취소 중" : "취소")
                                                .font(.custom("Pretendard-SemiBold", size: 12))
                                                .foregroundColor(Color("Gray1"))
                                                .padding(.horizontal, 14)
                                                .frame(height: 28)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.white)
                                                )
                                        }
                                        .disabled(cancellingApplyId != nil)
                                        .opacity(cancellingApplyId != nil ? 0.6 : 1)
                                    }
                                    .padding(.horizontal, 14)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color("White1"))
                                    )
                                }
                            }
                            .padding(.horizontal, 31)
                            .padding(.bottom, 20)
                            .padding(.top, 20)
                        }
                        .scrollIndicators(.hidden)
                    } else {
                        if !trimmedSearchText.isEmpty && filteredChats.isEmpty {
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                ChatEmptyView()
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            .offset(y: -60)
                        } else {
                            List {
                                ForEach(filteredChats) { chat in
                                    HStack(spacing: 0) {
                                        Image("profiles 1")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .padding(.trailing, 12)

                                        VStack(alignment: .leading, spacing: 0) {
                                            Text(chat.name)
                                                .font(.custom("Pretendard-SemiBold", size: 16))
                                                .foregroundColor(Color("Gray1"))

                                            Text("최근 한 대화 \(chat.lastMessage)")
                                                .font(.custom("Pretendard-Regular", size: 12))
                                                .foregroundColor(Color("Gray2"))
                                                .padding(.top, 3)
                                        }
                                    }
                                    .padding(.horizontal, 31)
                                    .padding(.top, 17)
                                    .padding(.bottom, 19)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedChat = chat
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .listRowBackground(Color.clear)
                                    .overlay(alignment: .bottom) {
                                        Rectangle()
                                            .fill(Color("Gray2"))
                                            .frame(height: 1)
                                            .padding(.horizontal, 31)
                                            .allowsHitTesting(false)
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea()
                .task {
                    do {
                        let rooms = try await chatService.fetchRooms()
                        await MainActor.run {
                            self.chats = rooms.map { r in
                                ChatItem(id: r.id, name: r.name, lastMessage: r.lastMessage, major: r.major, generation: r.generation)
                            }
                        }
                        if selectedTab == .request {
                            loadSentApplies()
                        }
                    } catch {
                        print("패치룸 에러 : ", error)
                    }
                }

                if isMentorModalPresented {
                    MentorRequestModal(
                        isPresented: $isMentorModalPresented,
                        items: $mentorRequests,
                        onAccept: handleAccept
                    )
                }
            }
            .onChange(of: selectedTab, perform: onTabChanged)
            .navigationDestination(item: $selectedChat) { chat in
                ChatRoomView(roomId: chat.id, title: chat.name)
            }
    }
}


#Preview("ChatView") {
    ChatView()
}

#Preview("Mentor 신청 목록 모달") {
    struct MentorModalPreviewHost: View {
        @State private var isPresented: Bool = true
        @State private var items: [MentorApplyDTO] = [
            .init(applyId: 1, menteeId: 0, mentorId: 0, name: "양은준", applyStatus: "PENDING", createdAt: ""),
            .init(applyId: 2, menteeId: 0, mentorId: 0, name: "문강현", applyStatus: "PENDING", createdAt: ""),
            .init(applyId: 3, menteeId: 0, mentorId: 0, name: "김준표", applyStatus: "PENDING", createdAt: "")
        ]

        var body: some View {
            ZStack {
                Color.white.ignoresSafeArea()
                MentorRequestModal(isPresented: $isPresented, items: $items, onAccept: { _ in })
            }
        }
    }

    return MentorModalPreviewHost()
}


// Move loadSentApplies into ChatView

extension ChatView {
    private func loadSentApplies() {
        Task {
            do {
                // NOTE: 프로젝트에 맞는 “내가 보낸 신청 목록” 메서드명으로 바꾸세요.
                // 예: fetchSentApplies / fetchMySentApplies / fetchAppliedMentors 등
                let res = try await mentorService.fetchSentApplies()
                await MainActor.run {
                    sentApplies = res.filter { $0.applyStatus.uppercased() == "PENDING" }
                }
            } catch {
                print("보낸 요청 조회 실패:", error)
            }
        }
    }
}
