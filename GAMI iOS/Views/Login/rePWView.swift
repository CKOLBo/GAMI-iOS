//
//  rePWView.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/23/25.
//


import SwiftUI

struct rePWView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    @State private var isNewPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false

    @State private var isSubmitting: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    @State private var navigateToHome: Bool = false

    private var canSubmit: Bool {
        !newPassword.isEmpty && !confirmPassword.isEmpty && !isSubmitting
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
            }
            .padding(.horizontal, 31)

            Spacer(minLength: 0)

           
            NavigationLink(isActive: $navigateToHome) {
                TabbarView()
            } label: {
                EmptyView()
            }
            .hidden()


            Button {
                submit()
            } label: {
                ZStack {
                    Text("완료")
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
        .overlay(alignment: .topLeading) {
            backButton()
                .padding(.leading, 16)
                .padding(.top, 12)
        }
    }
}

private extension rePWView {
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
            title: "새 비밀번호",
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
                Text("비밀번호가 동일합니다")
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
        
        guard newPassword.count >= 6 else {
            errorMessage = "비밀번호는 6자 이상 입력해 주세요."
            showError = true
            return
        }
        
        guard newPassword == confirmPassword else {
            return
        }
        
        isSubmitting = true
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isSubmitting = false
            navigateToHome = true
            
        }
    }
    
}

#Preview {
    rePWView()
}
