//
//  MyPostsView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//

import SwiftUI


struct MyPostsView: View {
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 0) {
                    Image("Back")
                        .padding(.trailing, 8)
                    Text("돌아가기")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(Color("Gray3"))
                }
            }
            
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
            .padding(.top, 16)

            
            Text("내가 쓴 글")
                .font(.custom("Pretendard-Bold", size: 32))
                .foregroundColor(Color.black)
                .padding(.top, 16)
                .padding(.leading, 32)
                
            myPostSearch(searchText: $searchText)
                .padding(.top, 50)
                .padding(.horizontal, 31)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MyPostsView()
    }
}
