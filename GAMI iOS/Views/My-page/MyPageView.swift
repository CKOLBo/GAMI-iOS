//
//  MyPageView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/22/25.
//

import SwiftUI

struct MyPageView: View {


    @StateObject private var vm = MyPageViewModel()

    @State private var selectedMajor: String = "FE"
    @State private var isMajorUpdating: Bool = false
    @State private var majorUpdateError: String? = nil

    // UI 칩 <-> 서버 enum 값 매핑
    private let majorToServer: [String: String] = [
        "FE": "FRONTEND",
        "BE": "BACKEND",
        "iOS": "IOS",
        "Android": "ANDROID",
        "Design": "DESIGN",
        "DevOps": "DEVOPS",
        "AI": "AI",
        "IT Network": "IT_NETWORK",
        "Flutter": "FLUTTER",
        "Cyber Security": "CYBER_SECURITY",
        "Game Development": "GAME_DEVELOPMENT",
        "Cloud Computing": "CLOUD_COMPUTING",
        "Mobile Robotics": "MOBILE_ROBOTICS"
    ]

    private let serverToMajor: [String: String] = [
        "FRONTEND": "FE",
        "BACKEND": "BE",
        "IOS": "iOS",
        "ANDROID": "Android",
        "DESIGN": "Design",
        "DEVOPS": "DevOps",
        "AI": "AI",
        "IT_NETWORK": "IT Network",
        "FLUTTER": "Flutter",
        "CYBER_SECURITY": "Cyber Security",
        "GAME_DEVELOPMENT": "Game Development",
        "CLOUD_COMPUTING": "Cloud Computing",
        "MOBILE_ROBOTICS": "Mobile Robotics"
    ]

    private var displayName: String { vm.profile?.name ?? "-" }
    private var displayGender: String {
        // 서버가 MALE/FEMALE 등으로 내려줄 수 있어서 UI용으로 변환
        let g = vm.profile?.gender ?? "-"
        if g.uppercased() == "MALE" { return "남자" }
        if g.uppercased() == "FEMALE" { return "여자" }
        return g
    }
    private var displayGrade: String {
        if let gen = vm.profile?.generation { return "\(gen)기" }
        return "-"
    }

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
                        name: displayName,
                        gender: displayGender,
                        grade: displayGrade,
                        onLogout: {
                            // ✅ 로그아웃: 토큰 제거 + 앱에 알림
                            UserDefaults.standard.removeObject(forKey: "accessToken")
                            UserDefaults.standard.removeObject(forKey: "refreshToken")
                            UserDefaults.standard.removeObject(forKey: "memberId")
                            NotificationCenter.default.post(
                                name: Notification.Name("didLogout"),
                                object: nil
                            )
                        }
                    )
                    .padding(.top, 28)
                    .padding(.horizontal, 24)

                    if let err = vm.errorMessage {
                        Text(err)
                            .font(.custom("Pretendard-Medium", size: 12))
                            .foregroundColor(.red)
                            .padding(.top, 12)
                            .padding(.horizontal, 24)
                    }

             
                    Text("전공")
                        .font(.custom("Pretendard-Bold", size: 24))
                        .foregroundStyle(Color("Gray1"))
                        .padding(.top, 76)
                        .padding(.horizontal, 39)

                    MajorChipGrid(
                        items: majors,
                        selected: $selectedMajor,
                        onSelect: { tapped in
                            majorUpdateError = nil
                            guard let serverValue = majorToServer[tapped] else {
                                majorUpdateError = "전공 매핑이 없어요: \(tapped)"
                                return
                            }
                            guard !isMajorUpdating else { return }

                            isMajorUpdating = true
                            Task { @MainActor in
                                await vm.changeMajor(serverValue)
                                isMajorUpdating = false
                                // 서버에서 내려온 값으로 UI도 다시 맞춤
                                if let serverMajor = vm.profile?.major {
                                    selectedMajor = serverToMajor[serverMajor] ?? selectedMajor
                                }
                            }
                        }
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, 39)
                   
                    if let majorUpdateError {
                        Text(majorUpdateError)
                            .font(.custom("Pretendard-Medium", size: 12))
                            .foregroundColor(.red)
                            .padding(.top, 10)
                            .padding(.horizontal, 39)
                    }

                   
                    
                }
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            await vm.load()
            if let serverMajor = vm.profile?.major {
                selectedMajor = serverToMajor[serverMajor] ?? selectedMajor
            }
        }
    }
}


private struct ProfileCardView: View {
    let name: String
    let gender: String
    let grade: String
    let onLogout: () -> Void

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

            Button {
                onLogout()
            } label: {
                Text("로그아웃")
                    .font(.custom("Pretendard-Bold", size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color("Blue1"))
                    .cornerRadius(18)
            }
            .buttonStyle(.plain)
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
    let onSelect: (String) -> Void

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
                    onSelect(item)
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


// MARK: - MyPage API ViewModel
@MainActor
final class MyPageViewModel: ObservableObject {
    @Published var profile: MyProfileDTO? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let memberService = MemberService()

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            profile = try await memberService.fetchMyProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func changeMajor(_ major: String) async {
        errorMessage = nil
        do {
            try await memberService.updateMajor(major)
            // 전공 수정 후 내 프로필 다시 조회
            profile = try await memberService.fetchMyProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


#Preview {
    MyPageView()
}
