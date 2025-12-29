//
//  ChatRoom.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/21/25.
//

import SwiftUI

struct ChatMessageUI: Identifiable, Hashable {
    let id: Int
    let text: String
    let isMe: Bool
    let senderName: String
    let createdAt: String
}

struct ChatRoomView: View {
    let roomId: Int
    let onLeave: (() -> Void)?

    @State private var title: String
    @State private var major: String = ""
    @State private var generation: Int = 0

    private let chatService = ChatService()

    init(roomId: Int, title: String = "", onLeave: (() -> Void)? = nil) {
        self.roomId = roomId
        self._title = State(initialValue: title)
        self.onLeave = onLeave
    }

    @Environment(\.dismiss) private var dismiss
    @State private var messageText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var showLeaveDialog: Bool = false

    @State private var messages: [ChatMessageUI] = []
    @State private var nextCursor: Int? = nil
    @State private var hasMore: Bool = true
    @State private var pendingSends: [String] = []
    @State private var didRequestSubscribe: Bool = false

    @StateObject private var socket = ChatSocketService()

    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { scrollProxy in
                ZStack {
                    VStack(spacing: 0) {
                        header
                            .padding(.top, geo.safeAreaInsets.top)

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
                                        .id(msg.id)
                                }

                                Spacer(minLength: 12)
                            }
                            .padding(.top, 24)
                            .padding(.horizontal, 20)
                        }
                        .onTapGesture {
                            isInputFocused = false
                        }
                        .onChange(of: messages.count) { _ in
                           
                            if let last = messages.last {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    scrollProxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: isInputFocused) { _ in
                         
                            if isInputFocused, let last = messages.last {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        scrollProxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .background(Color.white)
                    .safeAreaInset(edge: .bottom) {
                        inputBar
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(Color.white)
                    }
                    .onReceive(socket.$state) { st in
                        // 연결되면 딱 1번만 subscribe
                        if case .connected = st {
                            if !didRequestSubscribe {
                                didRequestSubscribe = true
                                socket.subscribe(roomId: roomId)
                            }
                            return
                        }

                        // subscribe 완료되면 pending send flush
                        if case .subscribed(let rid) = st, rid == roomId {
                            guard !pendingSends.isEmpty else { return }
                            let toSend = pendingSends
                            pendingSends.removeAll()
                            for text in toSend {
                                socket.sendMessage(roomId: roomId, message: text)
                            }
                        }
                    }

                    if showLeaveDialog {
                        LeaveChatDialog(
                            onCancel: { showLeaveDialog = false },
                            onLeave: {
                                showLeaveDialog = false
                                if let onLeave {
                                    onLeave()
                                } else {
                                    Task {
                                        do {
                                            try await chatService.leaveRoom(roomId: roomId)
                                        } catch {
                                            print("방 나가기 에러 :", error)
                                        }
                                        await MainActor.run { dismiss() }
                                    }
                                }
                            }
                        )
                        .transition(.opacity)
                    }
                }
            }
        }
        .task {
            await loadInitial(scrollToBottom: true)
        }
        .onAppear {
            let token = UserDefaults.standard.string(forKey: "accessToken") ?? ""
            guard !token.isEmpty else {
                print("❌ accessToken 비어서 소켓 연결 안 함")
                return
            }

            didRequestSubscribe = false

            socket.onMessage = { incoming in
                DispatchQueue.main.async {
                    if self.messages.contains(where: { $0.id == incoming.messageId }) {
                        return
                    }

                    let ui = ChatMessageUI(
                        id: incoming.messageId,
                        text: incoming.message,
                        isMe: (incoming.senderId == self.currentUserId && self.currentUserId != 0),
                        senderName: incoming.senderName,
                        createdAt: incoming.createdAt ?? ""
                    )
                    self.messages.append(ui)
                }
            }

            socket.connect(accessToken: token)
        }
        .onDisappear {
            socket.disconnect()
            didRequestSubscribe = false
        }
    }

    private var currentUserId: Int {
    
        if let v = UserDefaults.standard.object(forKey: "memberId") as? Int { return v }
        if let v = UserDefaults.standard.object(forKey: "userId") as? Int { return v }
        if let s = UserDefaults.standard.string(forKey: "memberId"), let v = Int(s) { return v }
        if let s = UserDefaults.standard.string(forKey: "userId"), let v = Int(s) { return v }
        return 0
    }

    @MainActor
    private func loadInitial(scrollToBottom: Bool) async {
        do {
           
            let detail = try await chatService.fetchRoomDetail(roomId: roomId)
            self.title = detail.name
            self.major = detail.major
            self.generation = detail.generation

            let res = try await chatService.fetchMessages(roomId: roomId, cursor: nil)
            self.nextCursor = res.nextCursor
            self.hasMore = res.hasMore

            self.messages = res.messages.map { m in
                ChatMessageUI(
                    id: m.messageId,
                    text: m.message,
                    isMe: (m.senderId == currentUserId && currentUserId != 0),
                    senderName: m.senderName,
                    createdAt: m.createdAt
                )
            }
        } catch {
            print("챗룸 로딩 에러요 : ", error)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
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
            }
            .offset(y: -50)

            HStack(spacing: 16) {
                Image("profiles 1")

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.custom("Pretendard-Bold", size: 20))
                        .foregroundColor(Color("Gray1"))

                    HStack(spacing: 8) {
                        Text("\(generation)기")
                            .font(.custom("Pretendard-Bold", size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("Blue1"))
                            .cornerRadius(4)

                        if !major.isEmpty {
                            Text(major)
                                .font(.custom("Pretendard-Bold", size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color("Purple1"))
                                .cornerRadius(4)
                        }
                    }
                }

                Spacer()

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
                }
                .buttonStyle(.plain)
            }
         
            Text(socketStatusText)
                .font(.custom("Pretendard-Medium", size: 12))
                .foregroundColor(Color("Gray3"))
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }


    private var socketStatusText: String {
        switch socket.state {
        case .disconnected:
            return "연결 안 됨"
        case .connecting:
            return "연결 중…"
        case .connected:
            return "연결됨 (구독 중…)"
        case .subscribed(let rid):
            return rid == roomId ? "실시간 연결됨" : "다른 방 구독 중"
        case .error(let msg):
            return "소켓 오류: \(msg)"
        }
    }


    private func dateChip(_ text: String) -> some View {
        Text(text)
            .font(.custom("Pretendard-Medium", size: 14))
            .foregroundColor(Color("Gray3"))
            .padding(.bottom, 21)
    }

    private func messageRow(_ msg: ChatMessageUI) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            if msg.isMe {
                Spacer(minLength: 0)
            } else {
                Image("profiles 1")
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
                .padding(.leading, msg.isMe ? 0 : 16)
                .padding(.trailing, msg.isMe ? 16 : 0)

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
                .focused($isInputFocused)
                .font(.custom("Pretendard-Bold", size: 12))
                .padding(.leading, 20)
                .foregroundStyle(Color("Gray3"))
                .frame(height: 46)

            Button {
                let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }

                let tempId = -Int(Date().timeIntervalSince1970 * 1000)
                let ui = ChatMessageUI(
                    id: tempId,
                    text: trimmed,
                    isMe: true,
                    senderName: "",
                    createdAt: ""
                )
                messages.append(ui)

               
                if case .subscribed(let rid) = socket.state, rid == roomId {
                    socket.sendMessage(roomId: roomId, message: trimmed)
                } else {
                    pendingSends.append(trimmed)
                    print("STOMP 에러 (pending=\(pendingSends.count))")
                }

                messageText = ""
                isInputFocused = true
            } label: {
                Text("보내기")
                    .font(.custom("Pretendard-Bold", size: 12))
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
        ChatRoomView(roomId: 1, title: "문강현")
    }
}
