//
//  MentorSearchBarView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/19/25.
//

import SwiftUI

struct MentorSearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        ZStack(alignment: .leading){
            Image("searchBar")
            
            HStack(){
                Image("search")
                    .padding(.leading, 21)
                
                TextField("익명게시판 검색",
                          text: $searchText,
                          prompt: Text("익명게시판 검색")
                    .font(.custom("Pretendard-Bold", size: 12))
                    .foregroundColor(Color("Gray3"))
                
                
                )
                    .font(.custom("Pretendard-Bold", size: 12))
                    .padding(.leading, 8)
                    .frame(width: 250)
                    .foregroundColor(Color("Gray3"))
                    .contentShape(Rectangle())
            }

           
        }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    MentorSearchBarView(searchText: $text)
}
