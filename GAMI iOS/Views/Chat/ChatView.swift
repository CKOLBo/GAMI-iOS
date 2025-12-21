//
//  ChatView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/21/25.
//

import SwiftUI

struct ChatItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let lastMessage: String
}

struct ChatRequestItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

struct MentorRequestItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

private struct MentorRequestModal: View {
    @Binding var isPresented: Bool
    @Binding var items: [MentorRequestItem]

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
                        .font(.custom("Pretendard-SemiBold", size: 12))
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

                                Text("\(item.name) 님께 요청이 보내졌어요.")
                                    .font(.custom("Pretendard-SemiBold", size: 10))
                                    .foregroundColor(Color("Gray3"))
                                    .lineLimit(1)

                                Spacer(minLength: 0)

                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        items.removeAll { $0.id == item.id }
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
    @State private var path: [String] = []
    @State private var searchText: String = ""
    @State private var requests: [ChatRequestItem] = [
        .init(name: "문강현"),
        .init(name: "김준표")
    ]
    @State private var isMentorModalPresented: Bool = false
    @State private var mentorRequests: [MentorRequestItem] = [
        .init(name: "양은준"),
        .init(name: "양은준"),
        .init(name: "양은준")
    ]

    private let chats: [ChatItem] = [
        .init(name: "9기 문강현", lastMessage: "대리미화하데대대대대"),
        .init(name: "9기 문강현", lastMessage: "대리미화하데대대대대"),
        .init(name: "9기 문강현", lastMessage: "대리미화하데대대대대"),
        .init(name: "9기 문강현", lastMessage: "대리미화하데대대대대"),
        .init(name: "9기 문강현", lastMessage: "대리미화하데대대대대")
    ]

    private var filteredChats: [ChatItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return chats }
        return chats.filter {
            $0.name.localizedCaseInsensitiveContains(q) ||
            $0.lastMessage.localizedCaseInsensitiveContains(q)
        }
    }

    private var filteredRequests: [ChatRequestItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return requests }
        return requests.filter { $0.name.localizedCaseInsensitiveContains(q) }
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
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
                            .onTapGesture { selectedTab = .request }

                        Spacer()

                        Image("Alarm")
                            .contentShape(Rectangle())
                            .onTapGesture { isMentorModalPresented = true }
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

                                        Text("\(item.name) 님한테 요청을 보냈어요.")
                                            .font(.custom("Pretendard-SemiBold", size: 14))
                                            .foregroundColor(Color("Gray3"))
                                            .lineLimit(1)
                                            .padding(.leading, 12)

                                        Spacer(minLength: 0)

                                        Button {
                                            withAnimation(.easeInOut(duration: 0.15)) {
                                                requests.removeAll { $0.id == item.id }
                                            }
                                        } label: {
                                            Text("취소")
                                                .font(.custom("Pretendard-SemiBold", size: 12))
                                                .foregroundColor(Color("Gray1"))
                                                .padding(.horizontal, 14)
                                                .frame(height: 28)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.white)
                                                )
                                        }
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
                                        path.append(chat.name)
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
                .navigationDestination(for: String.self) { name in
                    ChatRoomView(title: name)
                }
            }

            if isMentorModalPresented {
                MentorRequestModal(isPresented: $isMentorModalPresented, items: $mentorRequests)
            }
        }
    }
}


#Preview("ChatView") {
    ChatView()
}

#Preview("Mentor 신청 목록 모달") {
    struct MentorModalPreviewHost: View {
        @State private var isPresented: Bool = true
        @State private var items: [MentorRequestItem] = [
            .init(name: "양은준"),
            .init(name: "문강현"),
            .init(name: "김준표")
        ]

        var body: some View {
            ZStack {
                Color.white.ignoresSafeArea()
                MentorRequestModal(isPresented: $isPresented, items: $items)
            }
        }
    }

    return MentorModalPreviewHost()
}
