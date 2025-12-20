//
//  ChatRoom.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/21/25.
//



import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
}

struct ChatRoomView: View {
    let title: String

    @Environment(\.dismiss) private var dismiss
    @State private var messageText: String = ""

    @State private var messages: [ChatMessage] = [
        .init(text: "안녕 나는 깜둥이야", isMe: false),
        .init(text: "아아아", isMe: true),
        .init(text: "ㅁㅎㅇ", isMe: false),
        .init(text: "ㅁㅅㅎ", isMe: false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
g
            Rectangle()
                .fill(Color("Gray2"))
                .frame(height: 1)
                .padding(.horizontal, 24)

            ScrollView {
                LazyVStack(spacing: 14) {
                    dateChip("2025년 12월 03일")

                    ForEach(messages) { msg in
                        messageRow(msg)
                    }

                    Spacer(minLength: 12)
                }
                .padding(.top, 18)
                .padding(.horizontal, 20)
            }

            inputBar
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
    }

    private var header: some View {
        HStack(alignment: .top) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                    Text("돌아가기")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.black.opacity(0.85))
            }

            Spacer()

            Button {
           
            } label: {
                Text("나가기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.red.opacity(0.75))
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .overlay(alignment: .center) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(Color.gray.opacity(0.25))

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black.opacity(0.85))

                    HStack(spacing: 8) {
                        Text("9기")
                            .font(.custom("Pretendard-Bold", size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("Blue1"))
                            .cornerRadius(4)

                        Text("FE")
                            .font(.custom("Pretendard-Bold", size: 10))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("Purple1"))
                            .cornerRadius(4)
                        
                    }
                }
            }
            .offset(y: 34)
        }
        .padding(.bottom, 56)
    }

    private func tag(_ text: String, fill: Color) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6).fill(fill)
            )
    }

    private func dateChip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.gray.opacity(0.7))
            .padding(.vertical, 10)
    }

    private func messageRow(_ msg: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            if !msg.isMe {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(Color.gray.opacity(0.25))
            } else {
                Spacer(minLength: 0)
            }

            Text(msg.text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(msg.isMe ? .white : .black.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(msg.isMe ? Color.blue.opacity(0.7) : Color.gray.opacity(0.12))
                )
                .frame(maxWidth: 240, alignment: msg.isMe ? .trailing : .leading)

            if msg.isMe {
                EmptyView()
            } else {
                Spacer(minLength: 0)
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("메시지", text: $messageText)
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal, 16)
                .frame(height: 46)

            Button {
                let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                messages.append(.init(text: trimmed, isMe: true))
                messageText = ""
            } label: {
                Text("보내기")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.blue.opacity(0.8))
                    .padding(.trailing, 10)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .frame(height: 52)
    }
}

#Preview {
    NavigationStack {
        ChatRoomView(title: "양은준")
    }
}
