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

struct ChatView: View {

    enum Tab {
        case chat
        case request
    }

    @State private var selectedTab: Tab = .chat
    @State private var searchText: String = ""
    @State private var selectedChat: ChatItem? = nil

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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("채팅")
                        .font(.custom("Pretendard-Bold", size: 32))
                        .foregroundColor(Color("Gray1"))
                        .padding(.trailing, 12)
                        .padding(.leading, 32)

                    Rectangle()
                        .frame(width: 2, height: 32)
                        .foregroundColor(Color("Gray1"))
                        .cornerRadius(12)

                    Text("요청")
                        .font(.custom("Pretendard-Bold", size: 24))
                        .foregroundColor(Color("Gray2"))
                        .padding(.leading, 12)

                    Spacer()

                    Image("Alarm")
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
