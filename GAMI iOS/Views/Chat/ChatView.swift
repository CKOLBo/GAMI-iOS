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

struct ChatView: View {

    enum Tab {
        case chat
        case request
    }

    @State private var selectedTab: Tab = .chat
    @State private var searchText: String = ""
    @State private var selectedChat: ChatItem? = nil
    @State private var requests: [ChatRequestItem] = [
        .init(name: "문강현"),
        .init(name: "김준표")
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

    var body: some View {
        NavigationStack {
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

                    ZStack(alignment: .topTrailing) {
                        Image("Alarm")

                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                            .offset(x: 2, y: -2)
                    }
                    .padding(.trailing, 31)
                }
                .padding(.top, 60)
                .padding(.bottom, 43)

                ZStack(alignment: .leading){
                    Image("searchBar")

                    HStack(){
                        Image("search")
                            .padding(.leading, 21)

                        TextField("멘토 또는 멘티 검색",
                                  text: $searchText,
                                  prompt: Text("멘토 또는 멘티 검색")
                                    .font(.custom("Pretendard-Bold", size: 12))
                                    .foregroundColor(Color("Gray3"))
                        )
                        .font(.custom("Pretendard-Bold", size: 12))
                        .frame(width: 250)
                        .foregroundColor(Color("Gray3"))
                        .contentShape(Rectangle())
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
                    let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

                    if !q.isEmpty && filteredChats.isEmpty {
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
                                Button {
                                    selectedChat = chat
                                } label: {
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
                                }
                                .buttonStyle(.plain)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .listRowBackground(Color.clear)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(Color("Gray2"))
                                        .frame(height: 1)
                                        .padding(.horizontal, 31)
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
            .navigationDestination(item: $selectedChat) { chat in
                ChatRoomView(title: chat.name)
            }
            
        }
    }
}

#Preview {
    ChatView()
}
