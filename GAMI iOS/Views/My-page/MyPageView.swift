//
//  MyPageView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//

import SwiftUI

struct MyPageView: View {


    private let userName: String = "양은준"
    private let userGender: String = "남자"
    private let userGrade: String = "9기"

    @State private var selectedMajor: String = "FE"

    private let majors: [String] = [
        "FE", "BE", "iOS", "Mobile Robotics",
        "Android", "Design", "DevOps", "AI",
        "IT Network", "Flutter", "Cyber Security",
        "Game Development", "Cloud Computing"
    ]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

               
                    Text("마이페이지")
                        .font(.custom("Pretendard-Bold", size: 32))
                        .foregroundStyle(Color("Gray1"))
                        .padding(.top, 60)
                        .padding(.horizontal, 32)

               
                    ProfileCardView(
                        name: userName,
                        gender: userGender,
                        grade: userGrade
                    )
                    .padding(.top, 28)
                    .padding(.horizontal, 24)

             
                    Text("전공")
                        .font(.custom("Pretendard-Bold", size: 24))
                        .foregroundStyle(Color("Gray1"))
                        .padding(.top, 76)
                        .padding(.horizontal, 39)

                    MajorChipGrid(
                        items: majors,
                        selected: $selectedMajor
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, 39)
                   

                   
                    
                }
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


private struct ProfileCardView: View {
    let name: String
    let gender: String
    let grade: String

    var body: some View {
        HStack(spacing: 0) {
            ZStack {


                Image("profiles 1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    
                
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .font(.custom("Pretendard-Bold", size: 20))
                    .foregroundStyle(Color("Gray1"))
                    .padding(.bottom, 4)
                    

                HStack(spacing: 0) {
                    Text(gender)
                        .font(.custom("Pretendard-Bold", size: 10))
                        .foregroundStyle(Color("Gray3"))
                        

                    Text("|")
                        .font(.custom("Pretendard-Bold", size: 10))
                        .foregroundStyle(Color("Gray3"))
                        .padding(.horizontal,8)

                    Text(grade)
                        .font(.custom("Pretendard-Bold", size: 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color("Blue1"))
                        .cornerRadius(4)
                    
                        
                }
            }
            .padding(.leading, 16)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
        )
    }
}


private struct MajorChipGrid: View {
    let items: [String]
    @Binding var selected: String

    private let itemSpacing: CGFloat = 14

    var body: some View {
        FlowLayout(spacing: itemSpacing) {
            ForEach(items, id: \.self) { item in
                MajorChip(
                    title: item,
                    isSelected: selected == item
                )
                .onTapGesture {
                    selected = item
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MajorChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.custom("Pretendard-Medium", size: 14))
            .foregroundStyle(isSelected ? Color.white : Color("Gray3"))
            .lineLimit(1)
            .truncationMode(.tail)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 15)
            .padding(.vertical, 15)
            .background(
                Capsule()
                    .fill(isSelected ? Color("Purple1") : Color.white)
            )
            .overlay(
                Capsule()
                    .stroke(Color("Gray3"), lineWidth: isSelected ? 0 : 1)
            )
    }
}


private struct FlowLayout: Layout {
    var spacing: CGFloat = 14

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude

        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x > 0, x + size.width > maxWidth {
               
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            x += size.width
            if x < maxWidth { x += spacing }
            rowHeight = max(rowHeight, size.height)
        }

        return CGSize(width: proposal.width ?? x, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x > bounds.minX, x + size.width > bounds.maxX {
                
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}


private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MyPageView()
}
