//
//  Untitled.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/4/25.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 128)
                .padding(.top, 202)
            
            
            Text("멘토와 멘티를 연결하는 맞춤형 멘토링 서비스")
            .font(
            Font.custom("Pretendard", size: 20)
            .weight(.semibold)
            )
            .multilineTextAlignment(.center)
            .frame(width: 194, height: 48, alignment: .center)
    
            .padding(.top, 83)
        
            Spacer()
            
            Text("로그인")
                .font(
                Font.custom("Pretendard", size: 18)
                .weight(.bold)
                )
                .foregroundColor(.white)
                .padding(.horizontal, 135)
                .padding(.vertical, 14)
                .background(Color(red: 0.75, green: 0.66, blue: 1, opacity: 1))
            .cornerRadius(12)
            .padding(.bottom, 15)
            
            HStack(alignment: .center, spacing: 0) {
                
                Rectangle()
                .foregroundColor(Color(red: 0.72, green: 0.74, blue: 0.78))
                .frame(width: 128.00296, height: 1)
                .background(Color(red: 0.72, green: 0.74, blue: 0.78))
                .padding(.trailing, 12)
                .padding(.leading, 24)
                
                Text("처음이라면?")
                    .font(Font.custom("Pretendard", size: 14)
                        .weight(.medium))
                    .foregroundColor(.gray)

                
                Rectangle()
                    .foregroundColor(Color(red: 0.72, green: 0.74, blue: 0.78))
                .frame(width: 128.00296, height: 1)
                .padding(.trailing, 12)
                .padding(.leading, 24)
            }
            .padding(.bottom, 10)
            
            Text("회원가입")
                .font(
                Font.custom("Pretendard", size: 18)
                .weight(.bold)
                )
                .foregroundColor(.white)
                .padding(.horizontal, 135)
                .padding(.vertical, 14)
                .background(Color(red: 0.45, green: 0.66, blue: 1, ))
            .cornerRadius(12)
            .padding(.bottom, 32)
            }
            

        
        .navigationBarBackButtonHidden(true)
        
    }
}
#Preview {
    StartView()
}


