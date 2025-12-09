//
//  LoginView
//  GAMI iOS
//
//  Created by 김준표 on 12/8/25.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image("logo")
                .frame(width: 140, height: 112)
                .padding(.bottom, 52)
                .frame(maxWidth: .infinity, alignment: .center)

            
            Text("이메일")
                .font(Font.custom("Pretendard", size: 16))
                .foregroundColor(.gray)
                .padding(.vertical, 20)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal, 31)
                .padding(.bottom, 20)
            
            Text("비밀번호")
                .font(Font.custom("Pretendard", size: 16))
                .foregroundColor(.gray)
                .padding(.vertical, 20)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal, 31)
            
            HStack(){
                Text("비밀번호를 잊으셨나요?")
                    .font(
                        Font.custom("Pretendard", size: 14)
                    )
                    .foregroundColor(Color(.gray))
                    .padding(.leading, 31)
                    .padding(.top, 8)
                
                Text("비밀번호 찾기")
                    .font(
                        Font.custom("Pretendard", size: 14)
                    )
                    .foregroundColor(Color(.blue))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 31)
            }
           
        }
        .padding(.bottom, 385)
        VStack(alignment: .center, spacing: 0){
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
            .padding(.bottom, 32)
        }
        
    }
}
#Preview {
    LoginView()
}
