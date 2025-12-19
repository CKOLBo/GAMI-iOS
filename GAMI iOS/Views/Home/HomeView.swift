//
//  HomeView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/10/25.
//

import SwiftUI

struct BoardPost: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let likeCount: Int
    let commentCount: Int
}

struct HomeView: View{

    @State private var posts: [BoardPost] = [
        .init(title: "제목제목김준표", content: "내용내용내용김준표내용", likeCount: 3, commentCount: 3),
        .init(title: "제목제목김준표", content: "내용내용내용김준표내용", likeCount: 1, commentCount: 0),
        .init(title: "제목제목김준표", content: "내용내용내용김준표내용", likeCount: 12, commentCount: 4)
    ]

    var body: some View{
        ScrollView{
            VStack(alignment: .leading, spacing: 0){
                Text("홈")
                    .font(.custom( "Pretendard-Bold", size: 30)
                        )
                    .padding(.top,60)
                   
                VStack(alignment: .leading, spacing: 12) {
                    Text("양은준")
                        .font(.custom("Pretendard-Bold", size: 16))
                        .foregroundColor(Color("Gray3"))

                    HStack(spacing: 8) {
                        Text("남자")
                            .font(.custom("Pretendard-Bold", size: 10))
                            .foregroundColor(Color("Gray3"))

                        Rectangle()
                            .frame(width: 1, height: 14)
                            .foregroundColor(Color("Gray2"))

                        Text("9기")
                            .font(.custom("Pretendard-Bold", size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("Blue1"))
                            .cornerRadius(4)

                        Text("FE")
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
                
                
                MentorBar()
                    .padding(.top, 12)
                
                Text("익명게시판")
                    .font(.custom("Pretendard-Bold", size: 20))
                    .foregroundColor(Color("Gray1"))
                    .padding(.top, 28)
                
                LazyVStack(spacing: 12) {
                    ForEach(posts) { post in
                        BoardBar(post: post)
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
                .shadow(
                    color: Color.black.opacity(0.25),
                    radius: 12, x: 0, y: 6)
                .frame(width: 340, height: 80)
            
            Text("GAMI에 오신걸 환영합니다! 반가워요, 양은준님")
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
        .padding(.horizontal, 16)
    }
    
    func BoardBar(post: BoardPost) -> some View{
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

                HStack(spacing : 0){
                    Image("Hart")
                        .padding(.leading, 16)
                        .padding(.top, 15)
                        .padding(.bottom, 15)

                    Text("\(post.likeCount)")
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



#Preview{
    HomeView()
}
