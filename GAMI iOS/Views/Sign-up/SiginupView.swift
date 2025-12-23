//
//  SiginupView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/23/25.
//

import SwiftUI

struct SiginupView: View {
    @Environment(\.dismiss) private var dismiss
    private let authService = AuthService()

    @State private var name: String = ""
    @State private var email: String = ""

    @State private var selectedGrade: String = ""
    @State private var isGradeExpanded: Bool = false

    enum Gender {
        case male
        case female

        var title: String {
            switch self {
            case .male: return "남자"
            case .female: return "여자"
            }
        }
    }
    
    private var apiMajor: String {
        switch selectedMajor {
        case "FE": return "FRONTEND"
        case "BE": return "BACKEND"
        case "iOS": return "IOS"
        case "Android": return "ANDROID"
        case "Design": return "DESIGN"
        case "DevOps": return "DEVOPS"
        case "AI": return "AI"
        case "IT Network": return "IT_NETWORK"
        case "Flutter": return "FLUTTER"
        case "Cyber Security": return "CYBER_SECURITY"
        case "Game Development": return "GAME_DEVELOP"
        case "Cloud Computing": return "CLOUD_COMPUTING"
        case "Mobile Robotics": return "MOBILE_ROBOTICS"
        default: return selectedMajor
        }
    }


    @State private var selectedGender: Gender? = nil

    @State private var selectedMajor: String = ""

    @State private var isLoggingIn: Bool = false
    @State private var navigateToEmailView: Bool = false

    @State private var emailCodeInput: String = ""
    @State private var remainingSeconds: Int = 180

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    private var canSendCode: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedGrade.isEmpty &&
        selectedGender != nil &&
        !selectedMajor.isEmpty &&
        !isLoggingIn
    }
    
    
    private let majors: [String] = [
        "FE", "BE", "iOS", "Mobile Robotics",
        "Android", "Design", "DevOps", "AI",
        "IT Network", "Flutter", "Cyber Security",
        "Game Development", "Cloud Computing"
    ]
    
    var body: some View {

        
        NavigationStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 76)

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 112)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 52)

                VStack(alignment: .leading, spacing: 0) {
                    inputField(title: "이름", text: $name)
                        .padding(.bottom, 20)

                    inputField(title: "이메일", text: $email)
                        .padding(.bottom, 20)

                   
                    gradeDropdown()
                        .overlay(alignment: .topLeading) {
                            if isGradeExpanded {
                                gradeOptionsList()
                                    .padding(.top, 68)
                                    .transition(.opacity)
                                    .zIndex(2)
                            }
                        }
                        .zIndex(1)

                    genderToggleRow()
                        .padding(.top, 20)
                        .zIndex(0)

                    MajorChipGrid(items: majors, selected: $selectedMajor)
                        .padding(.top, 20)
                }
                .padding(.horizontal, 31)

                Spacer(minLength: 0)

                Button {
                    sendCode()
                } label: {
                    ZStack {
                        Text("인증번호 받기")
                            .font(.custom("Pretendard-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(canSendCode ? Color("Purple1") : Color("Gray4"))
                            .cornerRadius(12)

                        if isLoggingIn {
                            ProgressView()
                        }
                    }
                }
                .disabled(!canSendCode)
                .buttonStyle(.plain)
                .padding(.horizontal, 31)
                .padding(.bottom, 32)
                .padding(.top, 6)
            }
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .topLeading) {
                backButton()
                    .padding(.leading, 16)
                    .padding(.top, 12)
            }
            .navigationDestination(isPresented: $navigateToEmailView) {
                EmailVerifyView(
                    codeInput: $emailCodeInput,
                    email: email,
                    name: name,
                    generation: Int(selectedGrade.prefix(1)) ?? 0,
                    gender: selectedGender == .male ? "MALE" : "FEMALE",
                    major: apiMajor
                )
            }
            .alert("인증 실패", isPresented: $showError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}

private extension SiginupView {
    func backButton() -> some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Image("Back")
                Text("돌아가기")
                    .font(.custom("Pretendard", size: 16))
                    .foregroundColor(Color("Gray3"))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    func inputField(title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .keyboardType(title == "이메일" ? .emailAddress : .default)
            .font(.custom("Pretendard-Medium", size: 16))
            .foregroundColor(Color("Gray2"))
            .padding(.vertical, 20)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("Gray2"), lineWidth: 1)
            )
    }


    func gradeDropdown() -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                isGradeExpanded.toggle()
            }
        } label: {
            HStack {
                Text(selectedGrade.isEmpty ? "기수" : selectedGrade)
                    .font(.custom("Pretendard-Medium", size: 16))
                    .foregroundColor(selectedGrade.isEmpty ? Color("Gray2") : Color("Gray2"))

                Spacer()

                Image("qwe")
                    .rotationEffect(.degrees(isGradeExpanded ? 180 : 0))
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("Gray2"), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    func gradeOptionsList() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            gradeOptionRow("9기")
            gradeOptionRow("8기")
            gradeOptionRow("7기")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("Gray2"), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
        .contentShape(Rectangle())
    }

    func gradeOptionRow(_ value: String) -> some View {
        Button {
            selectedGrade = value
            withAnimation(.easeInOut(duration: 0.15)) {
                isGradeExpanded = false
            }
        } label: {
            Text(value)
                .font(.custom("Pretendard-Medium", size: 16))
                .foregroundColor(Color("Gray2"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
       
    }



    func genderToggleRow() -> some View {
        HStack(spacing: 20) {
            genderButton(.male)
            genderButton(.female)
        }
    }

    func genderButton(_ gender: Gender) -> some View {
        let isSelected = selectedGender == gender

        return Button {
            selectedGender = gender
        } label: {
            Text(gender.title)
                .font(.custom("Pretendard-Medium", size: 16))
                .foregroundColor(isSelected ? .white : Color("Gray3"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(isSelected ? Color("Purple1") : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.clear : Color("Gray2"), lineWidth: 2)
                )
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    func formatTime(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%d:%02d", min, sec)
    }

    func sendCode() {
        guard canSendCode else { return }
        isLoggingIn = true

        Task {
            do {
                let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                print("SEND CODE email =", email, "| trimmed =", trimmedEmail)

                try await authService.sendVerificationCode(
                    email: trimmedEmail,
                    verificationType: "SIGN_UP"
                )

                await MainActor.run {
                    isLoggingIn = false
                    remainingSeconds = 180
                    navigateToEmailView = true
                }
            } catch {
                let msg: String
                if let apiError = error as? APIError {
                    msg = apiError.localizedDescription
                } else {
                    msg = error.localizedDescription
                }

                await MainActor.run {
                    isLoggingIn = false
                    errorMessage = msg
                    showError = true
                }
            }
        }
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
                    .stroke(Color("Gray2"), lineWidth: isSelected ? 0 : 1)
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
    SiginupView()
}
