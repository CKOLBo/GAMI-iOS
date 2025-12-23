//
//  EmailView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/23/25.
//

import SwiftUI

struct EmailView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var showLoginError: Bool = false
    @State private var loginErrorMessage: String = ""
    @State private var isCodeSent: Bool = false
    @State private var sentCode: String = ""
    @State private var codeInput: String = ""

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

                if !isCodeSent {
                    inputField(title: "이메일", text: $email)
                        .padding(.bottom, 20)
                } else {
                    inputField(title: "인증번호", text: $codeInput)

                    HStack(spacing: 6) {
                        if remainingSeconds == 0 {
                            Text("시간이 만료되었어요")
                                .font(.custom("Pretendard-Medium", size: 14))
                                .foregroundColor(.red)
                        } else {
                            Text("")
                                .font(.custom("Pretendard-Medium", size: 14))
                                .foregroundColor(Color("Gray3"))

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
                                .foregroundColor(canResend ? .blue : Color("Blue1"))
                        }
                        .disabled(!canResend)
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 12)
                }
                
            }
            .padding(.horizontal, 31)

            Spacer(minLength: 0)

            Button {
                if isCodeSent {
                    verifyCode()
                } else {
                    sendCode()
                }
            } label: {
                ZStack {
                    Text(isCodeSent ? "인증하기" : "인증번호 받기")
                        .font(.custom("Pretendard-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background((isCodeSent ? codeInput.count == 6 : canSendCode) ? Color("Purple1") : Color("Gray4"))
                        .cornerRadius(12)

                    if isLoggingIn {
                        ProgressView()
                    }
                }
            }
            .disabled(isCodeSent ? codeInput.count != 6 : !canSendCode)
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
            guard isCodeSent, remainingSeconds > 0 else { return }
            remainingSeconds -= 1
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
            .keyboardType(title == "이메일" ? .emailAddress : .default)
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

        guard isEmailValid else {
            loginErrorMessage = "이메일 형식이 올바르지 않습니다."
            showLoginError = true
            return
        }

        isLoggingIn = true

        let code = String(format: "%06d", Int.random(in: 0...999999))
        sentCode = code

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isLoggingIn = false
            isCodeSent = true
            codeInput = ""
            remainingSeconds = 300
        }
    }

    func resendCode() {
        guard canResend else { return }
        let code = String(format: "%06d", Int.random(in: 0...999999))
        sentCode = code
        codeInput = ""
        remainingSeconds = 300
    }

    func verifyCode() {
        guard codeInput.count == 6 else { return }

        if codeInput == sentCode {
           
            dismiss()
        } else {
            return
        }
    }
}

#Preview {
    EmailView()
}
