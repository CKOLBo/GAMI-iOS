//
//  TabbarView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//

import SwiftUI

struct TabbarView: View {
    enum Tab: Hashable {
        case home, mentor, chat, board, mypage
    }

    @State private var selection: Tab = .home

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                HomeView(selection: $selection)
                    .tabItem {
                        Label("홈", image: "Home")
                    }
                    .tag(Tab.home)

                MentorFindView()
                    .tabItem {
                        Label("멘토찾기", image: "People")
                    }
                    .tag(Tab.mentor)

                ChatView()
                    .tabItem {
                        Label("채팅", image: "Chat")
                    }
                    .tag(Tab.chat)

                BoardHomeView()
                    .tabItem {
                        Label("익명게시판", image: "Peoples")
                    }
                    .tag(Tab.board)

                MyPageView()
                    .tabItem {
                        Label("마이페이지", image: "ME")
                    }
                    .tag(Tab.mypage)
            }
            .tint(Color("Purple1"))
        }
    }
}

#Preview {
    TabbarView()
}
