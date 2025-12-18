//
//  HomeView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/10/25.
//

import SwiftUI

struct HomeView: View{
    
    
    var body: some View{
        ScrollView{
            VStack(alignment: .leading, spacing: 0){
                Text("홈")
                    .font(.custom( "Pretendard-Bold", size: 30)
                        )
                    .padding(.top,60)
                   
                ZStack(alignment: .leading){
                    Text("양은준")
                        .font(.custom("Pretendard-Bold", size: 16))
                        .foregroundColor(Color("Gray3"))
                        .padding(.leading, 12)
                        .padding(.trailing, 286)
                        .padding(.top, 16)
                        .padding(.bottom, 45)
                        
                        .background(Color("White1"))
                        .cornerRadius(12)
                    
                    HStack(spacing:0){
                        Text("남자")
                            .font(.custom("Pretendard-Bold", size: 10))
                            .foregroundColor(Color("Gray3"))
                        Rectangle()
                            .frame(width: 1, height: 14)
                            .foregroundColor(Color("Gray2"))
                            .cornerRadius(12)
                            .padding(.horizontal, 8)
                        Text("9기")
                            .font(.custom("Pretendard-Bold", size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("Blue1"))
                            .cornerRadius(4)
                            .padding(.trailing, 4)
                        
                        Text("FE")
                            .font(.custom("Pretendard-Bold", size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("Purple1"))
                            .cornerRadius(4)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 54)
                    .padding(.bottom, 10)
                }
                .padding(.top, 3)
                
                Hello()
  
                Text("멘토찾기")
                    .font(.custom("Pretendard-Bold", size: 20))
                    .foregroundColor(Color("Gray1"))
                    .padding(.top, 28)
                
                
                Hi()
                    .padding(.top, 12)
                
                Text("익명게시판")
                    .font(.custom("Pretendard-Bold", size: 20))
                    .foregroundColor(Color("Gray1"))
                    .padding(.top, 28)
                
                Hoi()
                    .padding(.top, 12)
                  
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 32)
            
        }
    }
    func Hello() -> some View{
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
    
    func Hi() -> some View {
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
    
    func Hoi() -> some View{
        ZStack(){
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                
            
            VStack(){
                Text("제목제목김준표")
                    .font(.custom("Pretendard-Bold", size: 16))
                    .foregroundColor(Color("Gray1"))
                    .padding(.top, 20)
                    .padding(.leading, 16)
                Text("익명")
                    .font(.custom("Pretendard-Bold", size: 16))
                    .foregroundColor(Color("Gray1"))
            }

            .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        }
    }
}

#Preview{
    HomeView()
}
