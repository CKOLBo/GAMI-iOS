//
//  Untitled.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/4/25.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        VStack(alignment: .center){
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
        }
        .navigationBarBackButtonHidden(true)
        
    }
}
#Preview {
    StartView()
}


