//
//  LoginView
//  GAMI iOS
//
//  Created by 김준표 on 12/8/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss

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

                inputField(title: "이메일")
                    .padding(.bottom, 20)

                passwordField()

                forgotPasswordRow()
            }
            .padding(.horizontal, 31)

            Spacer(minLength: 0)

            Button(action: {}) {
                Text("로그인")
                    .font(.custom("Pretendard-Bold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.75, green: 0.66, blue: 1, opacity: 1))
                    .cornerRadius(12)
            }
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
            .background(Color.white.opacity(0.95))

        }
        .buttonStyle(.plain)
    }

    func inputField(title: String) -> some View {
        Text(title)
            .font(.custom("Pretendard-Medium", size: 16))
            .foregroundColor(.gray)
            .padding(.vertical, 20)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }

    func passwordField() -> some View {
        ZStack(alignment: .trailing) {
            Text("비밀번호")
                .font(.custom("Pretendard-Medium", size: 16))
                .foregroundColor(.gray)
                .padding(.vertical, 20)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 1)
                )

            HStack(spacing: 16) {
                Image("open eyes")
                Image("Close eyes")
            }
            .padding(.trailing, 18)
        }
    }

    func forgotPasswordRow() -> some View {
        HStack(spacing: 0) {
            Text("비밀번호를 잊으셨나요?")
                .font(.custom("Pretendard-Medium", size: 14))
                .foregroundColor(.gray)

            Spacer()

            Button(action: {}) {
                Text("비밀번호 찾기")
                    .font(.custom("Pretendard-Medium", size: 14))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }
}

#Preview {
    LoginView()
}
