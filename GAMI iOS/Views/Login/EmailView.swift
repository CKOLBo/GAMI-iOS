//
//  EmailView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/23/25.
//

import SwiftUI

struct EmailView: View {
    @Environment(\.dismiss) private var dismiss

    // EmailVerifyView에서 요구하는 회원가입 컨텍스트(EmailView에서는 임시값으로 유지)
    private let name: String = ""
    private let generation: Int = 0
    private let gender: String = "MALE"
    private let major: String = "FRONTEND"

    @State private var email: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var showLoginError: Bool = false
    @State private var loginErrorMessage: String = ""
    @State private var sentCode: String = ""
    @State private var codeInput: String = ""
    @State private var showVerifyView: Bool = false

    @State private var remainingSeconds: Int = 300
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var isEmailValid: Bool {
        email.contains("@gsm")
    }

    private var canSendCode: Bool {
        isEmailValid && !isLoggingIn
    }

    private var timeString: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private var canResend: Bool {
        remainingSeconds == 0
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

                    inputField(title: "이메일", text: $email)
                        .padding(.bottom, 20)
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
                
            }
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .topLeading) {
                backButton()
                    .padding(.leading, 16)
                    .padding(.top, 12)
            }
            .alert("로그인 실패", isPresented: $showLoginError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(loginErrorMessage)
            }
            .onReceive(timer) { _ in
                guard showVerifyView, remainingSeconds > 0 else { return }
                remainingSeconds -= 1
            }
            .navigationDestination(isPresented: $showVerifyView) {
                EmailVerifyView(
                    codeInput: $codeInput,
                    email: email,
                    name: name,
                    generation: generation,
                    gender: gender,
                    major: major
                )
            }
        }
    }
}

private extension EmailView {
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
            .keyboardType(.emailAddress)
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
    }

    func sendCode() {
        guard canSendCode else { return }

        isLoggingIn = true

        let code = String(format: "%06d", Int.random(in: 0...999999))
        sentCode = code

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isLoggingIn = false
            codeInput = ""
            remainingSeconds = 300
            showVerifyView = true
        }
    }

    func resendCode() {
        guard canResend else { return }
        let code = String(format: "%06d", Int.random(in: 0...999999))
        sentCode = code
        codeInput = ""
        remainingSeconds = 300
    }
}

#Preview {
    EmailView()
}
