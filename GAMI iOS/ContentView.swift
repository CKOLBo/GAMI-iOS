//
//  ContentView.swift
//  GAMI iOS
//
//  Created by 김준표 on 11/28/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .center){
            
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 166, height: 92)
                .padding(.vertical, 391)
                
            Spacer()
        }
        
    }
}
#Preview {
    ContentView()
}

