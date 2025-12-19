//
//  MantorFindView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/19/25.
//

import SwiftUI

struct MantorFindView: View {
    @State private var searchText: String = ""
    var body: some View {
        ScrollView{
            VStack(alignment: .leading ,spacing: 0){
                Text("멘토찾기")
                    .font(.custom("Pretendard-Bold", size: 32))
                    .padding(.top, 60)
                MentorSearchBarView(searchText: $searchText)
                    .padding(.top, 50)
                
            } .padding(.horizontal, 32)

            
            FindBar()
                .padding(.top,24)
                .padding(.horizontal, 31)
        }
        
        .frame(maxWidth: .infinity,alignment: .topLeading)
        .ignoresSafeArea()
        
    }
    
    func FindBar() -> some View{
        ZStack(){
            
            Image("ohing")
            
                .padding(.bottom, 52)
                .padding(.top, 8)
                .padding(.horizontal, 144)
                .background(Color.white)
               
                .cornerRadius(12)
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 12,
                    x: 0, y: 6
                )
            
            VStack(alignment: .leading){
                Text("당신에게 맞는 \n")
                +
                Text("멘토")
                    .foregroundColor(Color("Blue1"))
                +
                Text("를 못 찾겠다면?")
            }
            .font(.custom("Pretendard-Bold", size: 16))
            .padding(.top, 66)
            .padding(.bottom, 16)
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
 


        }
        
        
    }
}

#Preview {
    MantorFindView()
}
