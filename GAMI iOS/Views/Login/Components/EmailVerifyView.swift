//
//  EmailVerifyView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/23/25.
//

import SwiftUI

struct EmailVerifyView: View {
    @Environment(\.dismiss) private var dismiss

    private let authService = AuthService()

    let email: String
    let password: String
    let name: String
    let generation: Int
    let gender: String
    let major: String

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToHome: Bool = false

    @Binding var codeInput: String

    let remainingSeconds: Int
    let timeString: String
    let canResend: Bool
    let onTapResend: () -> Void

    @State private var isLoggingIn: Bool = false

    init(
        codeInput: Binding<String>,
        remainingSeconds: Int,
        timeString: String,
        canResend: Bool,
        onTapResend: @escaping () -> Void,
        email: String,
        password: String,
        name: String,
        generation: Int,
        gender: String,
        major: String
    ) {
        self._codeInput = codeInput
        self.remainingSeconds = remainingSeconds
        self.timeString = timeString
        self.canResend = canResend
        self.onTapResend = onTapResend

        self.email = email
        self.password = password
        self.name = name
        self.generation = generation
        self.gender = gender
        self.major = major
    }

   
    init(
        codeInput: Binding<String>,
        remainingSeconds: Int,
        timeString: String,
        canResend: Bool,
        onTapResend: @escaping () -> Void
    ) {
        self.init(
            codeInput: codeInput,
            remainingSeconds: remainingSeconds,
            timeString: timeString,
            canResend: canResend,
            onTapResend: onTapResend,
            email: "",
            password: "",
            name: "",
            generation: 0,
            gender: "MALE",
            major: ""
        )
    }

    private var canSendCode: Bool {
        !isLoggingIn
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 112)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 28)
                .padding(.bottom, 52)

            VStack(alignment: .leading, spacing: 0) {
                TextField("인증번호", text: $codeInput)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.numberPad)
                    .font(.custom("Pretendard-Medium", size: 16))
                    .foregroundColor(Color("Gray1"))
                    .padding(.vertical, 20)
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("Gray2"), lineWidth: 1)
                    )
                    .padding(.bottom, 12)
            }

            HStack(spacing: 6) {
                if remainingSeconds == 0 {
                    Text("시간이 만료되었어요")
                        .font(.custom("Pretendard-Medium", size: 14))
                        .foregroundColor(.red)
                } else {
                    Text(timeString)
                        .font(.custom("Pretendard-Medium", size: 14))
                        .foregroundColor(Color("Gray3"))
                }

                Spacer()

                Button {
                    onTapResend()
                } label: {
                    Text("재발송")
                        .font(.custom("Pretendard-Medium", size: 14))
                        .foregroundColor(canResend ? Color("Blue1") : Color("Gray3"))
                }
                .disabled(!canResend)
                .buttonStyle(.plain)
            }

            NavigationLink(isActive: $navigateToHome) {
                HomeView()
            } label: {
                EmptyView()
            }
            .hidden()

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 31)
        .background(Color.white.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .safeAreaInset(edge: .bottom) {
            Button {
                verifyAndSignup()
            } label: {
                ZStack {
                    Text("인증하기")
                        .font(.custom("Pretendard-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(canSendCode ? Color("Purple1") : Color("Gray4"))
                        .cornerRadius(12)

                    if isLoggingIn {
                        ProgressView()
                    }
                }
                .padding(.horizontal, 31)
                .padding(.bottom, 12)
            }
            .disabled(!canSendCode)
            .buttonStyle(.plain)
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image("Back")
                    Text("돌아가기")
                        .font(.custom("Pretendard", size: 16))
                        .foregroundColor(Color("Gray3"))
                }
                .padding(.vertical, 10)
            }
            .padding(.leading, 16)
            .padding(.top, 12)
            .buttonStyle(.plain)
        }
        .alert("회원가입 실패", isPresented: $showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private func verifyAndSignup() {
    
        guard !isLoggingIn else { return }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCode = codeInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            errorMessage = "이메일이 비어있어요."
            showError = true
            return
        }
        guard !password.isEmpty else {
            errorMessage = "비밀번호가 비어있어요."
            showError = true
            return
        }
        guard !trimmedCode.isEmpty else {
            errorMessage = "인증 코드를 입력해 주세요."
            showError = true
            return
        }

        isLoggingIn = true

        Task {
           
            defer {
                Task { @MainActor in
                    isLoggingIn = false
                }
            }

            do {
             
                try await authService.verifyEmailCode(email: trimmedEmail, code: trimmedCode)

          
                try await authService.signup(
                    email: trimmedEmail,
                    password: password,
                    name: name,
                    generation: generation,
                    gender: gender,
                    major: major
                )

               
                let res = try await authService.signin(email: trimmedEmail, password: password)

                UserDefaults.standard.set(res.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(res.refreshToken, forKey: "refreshToken")
                UserDefaults.standard.set(res.accessTokenExpiresIn, forKey: "accessTokenExpiresIn")
                UserDefaults.standard.set(res.refreshTokenExpiresIn, forKey: "refreshTokenExpiresIn")

                await MainActor.run {
                    navigateToHome = true
                }

            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    EmailVerifyView(
        codeInput: .constant("123456"),
        remainingSeconds: 120,
        timeString: "2:00",
        canResend: false,
        onTapResend: {},
        email: "test@test.com",
        password: "12345678",
        name: "테스트",
        generation: 9,
        gender: "MALE",
        major: "SOFTWARE"
    )
}
