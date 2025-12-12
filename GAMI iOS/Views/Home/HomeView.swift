//
//  HomeView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/10/25.
//

import SwiftUI

struct HomeView: View{
    
    init() {
        for family in UIFont.familyNames {
            print("== \(family) ==")
            for name in UIFont.fontNames(forFamilyName: family) {
                print(name)
            }
        }
    }
    
    var body: some View{
        ScrollView{
            VStack(alignment: .leading, spacing: 0){
                Text("홈")
                    .font(.custom( "Pretendard-Bold", size: 30)
                        )
                    .padding(.top,60)
                   
                
                    Text("a")
                    .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.leading, 32)
            
        }
    }
}

#Preview{
    HomeView()
}
