//
//  LoginView
//  GAMI iOS
//
//  Created by 김준표 on 12/8/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false

    @State private var isLoggingIn: Bool = false
    @State private var showLoginError: Bool = false
    @State private var loginErrorMessage: String = ""
    @State private var navigateToHome: Bool = false

    @State private var navigateToEmailView: Bool = false

    private var isEmailValid: Bool {
        
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    private var canLogin: Bool {
        isEmailValid && password.count >= 6 && !isLoggingIn
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

                passwordField()

                forgotPasswordRow()
            }
            .padding(.horizontal, 31)

            Spacer(minLength: 0)

           
            NavigationLink(isActive: $navigateToHome) {
                HomeView()
            } label: {
                EmptyView()
            }
            .hidden()

            NavigationLink(isActive: $navigateToEmailView) {
                EmailView()
            } label: {
                EmptyView()
            }
            .hidden()

            Button {
                login()
            } label: {
                ZStack {
                    Text("로그인")
                        .font(.custom("Pretendard-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canLogin ? Color("Purple1") : Color("Gray4"))
                        .cornerRadius(12)

                    if isLoggingIn {
                        ProgressView()
                    }
                }
            }
            .disabled(!canLogin)
            .buttonStyle(.plain)
            .padding(.horizontal, 31)
            .padding(.bottom, 32)
            
            }
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
    }
}

private extension LoginView {
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

    func passwordField() -> some View {
        ZStack(alignment: .trailing) {
            Group {
                if isPasswordVisible {
                    TextField("비밀번호", text: $password)
                } else {
                    SecureField("비밀번호", text: $password)
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
                isPasswordVisible.toggle()
            } label: {
                Image(isPasswordVisible ? "open eyes" : "Close eyes")
            }
            .padding(.trailing, 18)
            .buttonStyle(.plain)
            .contentShape(Rectangle())
        }
    }

    func forgotPasswordRow() -> some View {
        HStack(spacing: 0) {
            Text("비밀번호를 잊으셨나요?")
                .font(.custom("Pretendard-Medium", size: 14))
                .foregroundColor(.gray)

            Spacer()

            Button {
                navigateToEmailView = true
            } label: {
                Text("비밀번호 찾기")
                    .font(.custom("Pretendard-Medium", size: 14))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }

    func login() {
        guard canLogin else { return }

       
        guard isEmailValid else {
            loginErrorMessage = "이메일 형식이 올바르지 않습니다."
            showLoginError = true
            return
        }

        guard password.count >= 6 else {
            loginErrorMessage = "비밀번호는 6자 이상 입력해 주세요."
            showLoginError = true
            return
        }

        isLoggingIn = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isLoggingIn = false



            navigateToHome = true
        }
    }
}

#Preview {
    LoginView()
}
