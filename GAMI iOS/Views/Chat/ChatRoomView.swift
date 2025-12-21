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
    let onLeave: (() -> Void)?
    
    init(title: String, onLeave: (() -> Void)? = nil) {
        self.title = title
        self.onLeave = onLeave
    }

    @Environment(\.dismiss) private var dismiss
    @State private var messageText: String = ""
    @State private var showLeaveDialog: Bool = false

    @State private var messages: [ChatMessage] = [
        .init(text: "안녕 나는 깜둥이야", isMe: false),
        .init(text: "아아아", isMe: true),
        .init(text: "ㅁㅎㅇ", isMe: false),
        .init(text: "ㅁㅅㅎ", isMe: false),
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                
                Rectangle()
                    .fill(Color("Gray2"))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                    .padding(.top, 26)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        dateChip("2025년 12월 03일")
                        ForEach(messages) { msg in
                            messageRow(msg)
                        }

                        Spacer(minLength: 12)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 20)
                }

                inputBar
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
            }
            .navigationBarBackButtonHidden(true)
            .background(Color.white)
            .ignoresSafeArea()

            if showLeaveDialog {
                LeaveChatDialog(
                    onCancel: { showLeaveDialog = false },
                    onLeave: {
                        showLeaveDialog = false
                        if let onLeave {
                            onLeave()
                        } else {
                            dismiss()
                        }
                    }
                )
                .transition(.opacity)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image("Back")
                    Text("돌아가기")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(Color("Gray3"))
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
            .padding(.top, 16)

            Button {
                showLeaveDialog = true
            } label: {
                Text("나가기")
                    .font(.custom("Pretendard-Bold", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 17.5)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("Red1"))
                    )
            } .padding(.leading, 20)
                .padding(.top, 92)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .overlay(alignment: .center) {
            HStack(spacing: 0) {
                Image("profiles 1")

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.custom("Pretendard-Bold", size: 20))
                        .foregroundColor(Color("Gray1"))
                        .padding(.bottom, 6)

                    HStack(spacing: 0) {
                        Text("9기")
                            .font(.custom("Pretendard-Bold", size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("Blue1"))
                            .cornerRadius(4)
                            
                            .padding(.trailing,8)

                        Text("FE")
                            .font(.custom("Pretendard-Bold", size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("Purple1"))
                            .cornerRadius(4)
                    }
                }
                .padding(.leading, 16)
            }
            .padding(.top, 84)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 28)
            
        }
        
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
            .font(.custom("Pretendard-Medium", size: 14))
            .foregroundColor(Color("Gray3"))
            .padding(.bottom, 21)
    }

    private func messageRow(_ msg: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            if !msg.isMe {
                Image("profiles 1")
            } else {
                Spacer(minLength: 0)
            }
                
            Text(msg.text)
                .font(.custom("Pretendard-SemiBold", size: 14))
                .foregroundColor(msg.isMe ? Color.white : Color("Gray1"))
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(msg.isMe ? Color.blue.opacity(0.7) : Color.gray.opacity(0.12))
                )
                .frame(maxWidth: 240, alignment: msg.isMe ? .trailing : .leading)
                .padding(.leading, 16)

            if msg.isMe {
                EmptyView()
            } else {
                Spacer(minLength: 0)
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 0) {
            TextField("", text: $messageText, prompt: Text("메시지").foregroundStyle(Color("Gray3")))
                .font(.custom("Pretendard-Bold", size: 12))
                .padding(.leading, 20)
                .foregroundStyle(Color("Gray3"))
                .frame(height: 46)

            Button {
                let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                messages.append(.init(text: trimmed, isMe: true))
                messageText = ""
            } label: {
                Text("보내기")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Blue1"))
                    .padding(.trailing, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("White1"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color("Gray4"), lineWidth: 1)
        )
        .frame(height: 52)
    }
}

private struct LeaveChatDialog: View {
    let onCancel: () -> Void
    let onLeave: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(alignment: .leading, spacing: 0) {

                VStack(alignment: .leading, spacing: 0) {
                    Text("채팅방 나가기")
                        .font(.custom("Pretendard-Bold", size: 20))
                        .foregroundStyle(Color("Gray1"))
                        .padding(.bottom, 60)

                    Text("정말 나가시겠어요?")
                        .font(.custom("Pretendard-Bold", size: 12))
                        .foregroundStyle(Color("Gray1"))
                    
                    Text("나가기를 누른 시 더이상 상대와 채팅을 할 수 없어요.")
                        .font(.custom("Pretendard-SemiBold", size: 12))
                        .foregroundStyle(Color("Gray3"))
                        .padding(.bottom, 56)
                }
                .padding(.top, 16)
                .padding(.horizontal, 22)

                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("취소")
                            .font(.custom("Pretendard-Bold", size: 14))
                            .foregroundStyle(Color("Gray1"))
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("Gray4"), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: onLeave) {
                        Text("나가기")
                            .font(.custom("Pretendard-Bold", size: 14))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("Red1"))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 22)
                .padding(.horizontal, 22)
                .padding(.bottom, 18)
            }
            .frame(maxWidth: 330)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .padding(.horizontal, 28)
        }
    }
}

#Preview {
    NavigationStack {
        ChatRoomView(title: "문강현")
    }
}
