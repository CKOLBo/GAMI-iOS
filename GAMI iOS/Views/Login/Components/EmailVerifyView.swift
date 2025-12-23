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
    let name: String
    let generation: Int
    let gender: String
    let major: String

    @Binding var codeInput: String

    init(
        codeInput: Binding<String>,
        email: String,
        name: String,
        generation: Int,
        gender: String,
        major: String
    ) {
        self._codeInput = codeInput
        self.email = email
        self.name = name
        self.generation = generation
        self.gender = gender
        self.major = major
    }

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToSginPW: Bool = false

    // 5분 타이머 (300초)
    @State private var remainingSeconds: Int = 300
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var timeString: String {
        let min = remainingSeconds / 60
        let sec = remainingSeconds % 60
        return String(format: "%d:%02d", min, sec)
    }

    private var canResend: Bool {
        remainingSeconds == 0
    }

    @State private var isLoggingIn: Bool = false

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
                    resendCode()
                } label: {
                    Text("재발송")
                        .font(.custom("Pretendard-Medium", size: 14))
                        .foregroundColor(canResend ? Color("Blue1") : Color("Gray3"))
                }
                .disabled(!canResend)
                .buttonStyle(.plain)
            }

            NavigationLink(isActive: $navigateToSginPW) {
                RePWView(
                    email: email,
                    name: name,
                    generation: generation,
                    gender: gender,
                    major: major
                )
            } label: {
                EmptyView()
            }
            .hidden()

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 31)
        .background(Color.white.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onReceive(timer) { _ in
            guard remainingSeconds > 0 else { return }
            remainingSeconds -= 1
        }
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

                await MainActor.run {
                    navigateToSginPW = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func resendCode() {
        guard !isLoggingIn else { return }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "이메일이 비어있어요."
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
                try await authService.sendVerificationCode(
                    email: trimmedEmail,
                    verificationType: "SIGN_UP"
                )

                await MainActor.run {
                    remainingSeconds = 300
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
        email: "test@test.com",
        name: "테스트",
        generation: 9,
        gender: "MALE",
        major: "FRONTEND"
    )
}
