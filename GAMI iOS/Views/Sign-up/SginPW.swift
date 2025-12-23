//
//  SginPW.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/23/25.
//

import SwiftUI

struct RePWView: View {
    
    let email: String
    let name: String
    let generation: Int
    let gender: String
    let major: String

    private let authService = AuthService()

    @Environment(\.dismiss) private var dismiss

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    @State private var isNewPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false

    @State private var isSubmitting: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    @State private var navigateToMainTab: Bool = false

  
    @State private var agreeAll: Bool = false
    @State private var agreeService: Bool = false
    @State private var agreePrivacy: Bool = false

    @State private var isServiceTermsPresented: Bool = false
    @State private var isPrivacyTermsPresented: Bool = false

    private var canSubmit: Bool {
        !newPassword.isEmpty
        && !confirmPassword.isEmpty
        && agreeService
        && agreePrivacy
        && !isSubmitting
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: 76)
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 112)
                    .frame(maxWidth: .infinity, alignment: .center)
                   
                    .padding(.bottom, 52)

                newPasswordField()
                    .padding(.bottom, 20)

                confirmPasswordField()
                
                passwordMatchStatusView()
                
                Terms()
                    .padding(.top, 20)
                    .onChange(of: agreeAll) { _, newValue in
                       
                        agreeService = newValue
                        agreePrivacy = newValue
                    }
                    .onChange(of: agreeService) { _, _ in
                    
                        agreeAll = agreeService && agreePrivacy
                    }
                    .onChange(of: agreePrivacy) { _, _ in
                        agreeAll = agreeService && agreePrivacy
                    }

                
            }
            .padding(.horizontal, 31)

            Spacer(minLength: 0)

           
            NavigationLink(isActive: $navigateToMainTab) {
                TabbarView()
            } label: {
                EmptyView()
            }
            .hidden()


            Button {
                submit()
            } label: {
                ZStack {
                    Text("회원가입")
                        .font(.custom("Pretendard-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canSubmit ? Color("Purple1") : Color("Gray4"))
                        .cornerRadius(12)

                    if isSubmitting {
                        ProgressView()
                    }
                }
            }
            .disabled(!canSubmit)
            .buttonStyle(.plain)
            .padding(.horizontal, 31)
            .padding(.bottom, 32)
            
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert("오류", isPresented: $showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $isServiceTermsPresented) {
            TermsDetailView(title: "GAMI 이용약관", kind: .service)
        }
        .sheet(isPresented: $isPrivacyTermsPresented) {
            TermsDetailView(title: "개인정보 수집 및 이용", kind: .privacy)
        }
        .overlay(alignment: .topLeading) {
            backButton()
                .padding(.leading, 16)
                .padding(.top, 12)
        }
    }
}

private extension RePWView {
    func validatePassword(_ pw: String) -> String? {
     
        guard pw.count >= 8 else { return "비밀번호는 8자 이상 입력해 주세요." }

        
        let hasUpper = pw.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLower = pw.rangeOfCharacter(from: .lowercaseLetters) != nil
        guard hasUpper && hasLower else { return "비밀번호는 영문 대문자와 소문자를 모두 포함해야 합니다." }

       
        return nil
    }
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
    
    func newPasswordField() -> some View {
        passwordField(
            title: "비밀번호",
            text: $newPassword,
            isVisible: $isNewPasswordVisible
        )
    }
    
    func confirmPasswordField() -> some View {
        passwordField(
            title: "비밀번호 확인",
            text: $confirmPassword,
            isVisible: $isConfirmPasswordVisible
        )
    }
    
    func passwordMatchStatusView() -> some View {
        Group {
            if confirmPassword.isEmpty {
                EmptyView()
            } else if newPassword == confirmPassword {
                Text("비밀번호 조건을 만족하며 동일합니다")
                    .font(.custom("Pretendard-Medium", size: 12))
                    .foregroundColor(Color.green)
                    .padding(.top, 8)
            } else {
                Text("비밀번호가 동일하지 않습니다.")
                    .font(.custom("Pretendard-Medium", size: 12))
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
    }
    
    func Terms() -> some View {
        VStack(alignment: .leading, spacing: 0) {

         
            Button {
                agreeAll.toggle()
            } label: {
                ZStack(alignment: .leading) {
                    Text("전체 이용 약관")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(Color("Gray3"))
                        .padding(.leading, 48)
                        .padding(.trailing, 200)
                        .padding(.vertical, 20)
                        .background(Color("White1"))
                        .cornerRadius(8)

                    CheckBox(isOn: agreeAll)
                        .padding(.leading, 20)
                        .padding(.trailing, 8)
                        .padding(.top, 2)
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 0) {
                Button {
                    agreeService.toggle()
                } label: {
                    CheckBox(isOn: agreeService)
                        .padding(.leading, 20)
                        .padding(.trailing, 8)
                        .padding(.top, 2)
                }
                .buttonStyle(.plain)

                Text("[필수] GAMI 이용 약관에 동의")
                    .font(.custom("Pretendard-Medium", size: 14))
                    .foregroundColor(Color("Gray3"))

                Spacer(minLength: 0)

                Button {
                    isServiceTermsPresented = true
                } label: {
                    Image("app")
                        .padding(4.5)
                        .background(Color("White1"))
                        .cornerRadius(100)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 16)

            
            HStack(spacing: 0) {
                Button {
                    agreePrivacy.toggle()
                } label: {
                    CheckBox(isOn: agreePrivacy)
                        .padding(.leading, 20)
                        .padding(.trailing, 8)
                        .padding(.top, 2)
                }
                .buttonStyle(.plain)

                Text("[필수] 개인정보 수집 및 이용에 동의")
                    .font(.custom("Pretendard-Medium", size: 14))
                    .foregroundColor(Color("Gray3"))

                Spacer(minLength: 0)

                Button {
                    isPrivacyTermsPresented = true
                } label: {
                    Image("app")
                        .padding(4.5)
                        .background(Color("White1"))
                        .cornerRadius(100)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 23)
        }
    }
    
    func passwordField(title: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        ZStack(alignment: .trailing) {
            Group {
                if isVisible.wrappedValue {
                    TextField(title, text: text)
                } else {
                    SecureField(title, text: text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .font(.custom("Pretendard-Medium", size: 16))
            .foregroundColor(Color("Gray1"))
            .padding(.vertical, 20)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("Gray4"), lineWidth: 1)
            )
            
            Button {
                isVisible.wrappedValue.toggle()
            } label: {
                Image(isVisible.wrappedValue ? "open eyes" : "Close eyes")
            }
            .padding(.trailing, 18)
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
    }
    
    func submit() {
        guard canSubmit else { return }

        if let msg = validatePassword(newPassword) {
            errorMessage = msg
            showError = true
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "비밀번호가 동일하지 않습니다."
            showError = true
            return
        }

        isSubmitting = true

        Task {
            do {
                let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        
                try await authService.signup(
                    email: trimmedEmail,
                    password: newPassword,
                    name: name,
                    generation: generation,
                    gender: gender,
                    major: major
                )

                
                let res = try await authService.signin(
                    email: trimmedEmail,
                    password: newPassword
                )

                UserDefaults.standard.set(res.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(res.refreshToken, forKey: "refreshToken")
                UserDefaults.standard.set(res.accessTokenExpiresIn, forKey: "accessTokenExpiresIn")
                UserDefaults.standard.set(res.refreshTokenExpiresIn, forKey: "refreshTokenExpiresIn")

                await MainActor.run {
                    isSubmitting = false
                    navigateToMainTab = true
                }
            } catch {
                let msg: String
                if let apiError = error as? APIError {
                    msg = apiError.localizedDescription
                } else {
                    msg = error.localizedDescription
                }

                await MainActor.run {
                    isSubmitting = false
                    errorMessage = msg
                    showError = true
                }
            }
        }
    }
    
}

#Preview {
    RePWView(
        email: "test@gsm.hs.kr",
        name: "테스트",
        generation: 1,
        gender: "MALE",
        major: "FRONTEND"
    )
}


private struct CheckBox: View {
    let isOn: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2.25)
                .stroke(Color("Gray2"), lineWidth: 1)
                .frame(width: 20, height: 20)

            if isOn {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color("Purple1"))
            }
        }
    }
}


private enum TermsKind {
    case service
    case privacy
}

private struct TermsDetailView: View {
    let title: String
    let kind: TermsKind

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("Gray3"))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                Text(title)
                    .font(.custom("Pretendard-Bold", size: 18))
                    .foregroundColor(Color("Gray1"))

                Spacer(minLength: 0)

             
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

     
            ScrollView(.vertical, showsIndicators: true) {
                Text(termsText)
                    .font(.custom("Pretendard-Medium", size: 13))
                    .foregroundColor(Color("Gray2"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
            }
        }
        .presentationDragIndicator(.visible)
        .background(Color.white)
    }

    private var termsText: String {
        switch kind {
        case .service:
            return """
GAMI 이용약관

환영합니다.

GAMI를 이용해주셔서 감사합니다.
서비스를 이용하시기 전 회원으로 가입하실 경우 본 약관에 동의하시게 되므로, 잠시 시간을 내어서 주의 깊게 살펴봐 주시기 바랍니다.

GAMI 이용약관(오원본)
시행일: 2025.12.01
운영주체: 팀 CKOLB
문의: ckolb.gami@gmail.com

제 1조(목적)
본 약관은 팀 CKOLB(이하 “운영팀”)이 제공하는 GAMI 서비스 이용과 관련된 기본 사항을 정함니다.

제2조(대상 및 가입)
1. 서비스 이용 대상은 광주소프트웨어마이스터고 재학생입니다.
2. 회원가입 시 다음 정보를 입력합니다: 이름, 성별, 기수, 전공, 교내 이메일.
3. 회원은 이용약관에 동의하여야 하며, 개인정보 수집·이용 동의는 별도로 진행됩니다.

제3조(서비스 내용)
- 멘토 찾기
- 회원 간 채팅
- 익명게시판

제4조(게시판 운영 및 게시물 조치)
1. 이용자는 서비스를 악용으로 게시물을 작성할 수 없습니다.
2. 운영팀은 아래에 해당하는 게시물은 사전 통지 없이 삭제할 수 있습니다:
- 광고·홍보·스팸
- 욕설·비방·혐오 표현
- 개인정보 노출
- 음란·불법 콘텐츠
- 권리 침해 및 부적절한 내용

제5조(금지행위)
회원은 다음 행위를 해서는 안 됩니다.
1. 광고·홍보성 서비스 유도
2. 욕설·비방·혐오 표현을 주도하는 행위
3. 개인정보 노출·수집·유포
4. 음란하거나 성적 수치심을 유발하는 내용 게시
5. 게시판 목적과 무관한 반복 게시, 분란 조장
6. 서비스 운영 방해(과도한 요청, 악성 이용 등)
7. 계정 도용 또는 재학생이 아닌 자의 이용

제6조(이용제한 및 탈퇴)
1. 운영팀은 약관 위반 시 다음 조치를 할 수 있습니다.
- 경고
- 기간 이용 제한
- 계정 이용 정지
2. 회원은 서비스 내 탈퇴 또는 운영팀 안내에 따라 탈퇴를 요청할 수 있습니다.

제7조(서비스 변경·중단)
운영팀은 점검, 유지보수, 시스템 장애 등 운영상 필요가 있거나 약관 위반이 확인될 경우 서비스의 전부 또는 일부를 제한하거나 중지할 수 있습니다.

제8조(책임 제한)
1. 운영팀은 서비스의 안정적 제공을 위해 노력합니다.
2. 다만, 불가항력(시스템 장애, 외부 요인)으로 인한 손해에 대해서는 책임이 제한될 수 있습니다.
"""

        case .privacy:
            return """
GAMI 개인정보 수집·이용 동의서

서비스명: GAMI
개인정보처리자(운영주체): 팀 CKLOB
문의: cklob.gami@gmail.com
동의서 버전: v1 / 시행일: 2025.12.01

1. 개인정보 수집·이용에 관한 안내(고지)
운영팀은 회원가입 및 서비스 제공을 위해 아래와 같이 개인정보를 수집·이용합니다. (동의 시에 목적, 항목, 보유·이용기간, 동의 거부권 및 불이익을 고지하여야 함)

[필수] 수집·이용 내역
- 수집·이용 목적: 회원가입, 서비스 제공, 공지 및 문의응대
- 수집 항목: 이름, 성별, 기수, 전공, 교내 이메일
- 보유·이용 기간: 회원 탈퇴 시까지

2. 동의 거부 권리 및 동의 거부 시 불이익
- 이용자는 개인정보 수집·이용에 대한 동의를 거부할 권리가 있습니다.
- 다만, 위 개인정보는 회원가입 및 서비스 제공에 필요한 필수 항목이므로 동의를 거부할 경우 회원가입 및 서비스 이용이 제한될 수 있습니다.

※ 본 동의는 이용약관 동의 등 다른 동의와 구분하여 받습니다.
"""
        }
    }
}
