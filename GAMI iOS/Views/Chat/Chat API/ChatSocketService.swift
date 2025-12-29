//
//  ChatSocketService.swift
//  GAMI iOS
//
//  Created by 김준표 on 12/28/25.
//
import Foundation


final class ChatSocketService: ObservableObject {

  

    enum ConnectionState: Equatable {
        case disconnected
        case connecting
        case connected
        case subscribed(roomId: Int)
        case error(String)
    }


    struct IncomingMessage: Decodable, Hashable {
        let messageId: Int
        let message: String
        let createdAt: String?
        let senderId: Int
        let senderName: String
    }

    

    @Published private(set) var state: ConnectionState = .disconnected



    var onMessage: ((IncomingMessage) -> Void)?

    

    init(webSocketURL: URL? = nil) {
        let candidates = ChatSocketService.makeCandidateWebSocketURLs(override: webSocketURL)
        self.candidateWebSocketURLs = candidates
        self.webSocketURL = candidates.first ?? URL(string: "wss://port-0-gami-server-mj0rdvda8d11523e.sel3.cloudtype.app/ws-stomp")!
    }

    private static func makeCandidateWebSocketURLs(override: URL? = nil) -> [URL] {
        if let override { return [override] }

        // ✅ iOS는 순수 WebSocket(STOMP) 전용 엔드포인트 사용
        // 백엔드: registry.addEndpoint("/ws-stomp")
        let raw = (Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String) ?? ""

        let pathCandidates: [String] = [
            "/ws-stomp"
        ]

        func buildURLs(host: String, schemes: [String]) -> [URL] {
            var urls: [URL] = []
            for scheme in schemes {
                for path in pathCandidates {
                    if let u = URL(string: "\(scheme)://\(host)\(path)") {
                        urls.append(u)
                    }
                }
            }
            // De-dupe while preserving order
            var seen = Set<String>()
            return urls.filter { seen.insert($0.absoluteString).inserted }
        }

        if let restURL = URL(string: raw), let host = restURL.host {
            let hostWithPort: String = {
                if let port = restURL.port { return "\(host):\(port)" }
                return host
            }()

            // ✅ HTTPS 도메인이면 반드시 wss 로 연결 (백엔드 요구사항)
            // http(로컬)일 때만 ws 사용
            let schemes: [String]
            if restURL.scheme?.lowercased() == "http" {
                schemes = ["ws"]
            } else {
                schemes = ["wss"]
            }

            let urls = buildURLs(host: hostWithPort, schemes: schemes)
            if !urls.isEmpty { return urls }
        }

        // Fallback hardcoded host
        return buildURLs(
            host: "port-0-gami-server-mj0rdvda8d11523e.sel3.cloudtype.app",
            schemes: ["wss"]
        )
    }

    private var webSocketURL: URL
    private let candidateWebSocketURLs: [URL]
    private var wsCandidateIndex: Int = 0


    private func retryWithNextWebSocketURLIfPossible(reason: String) {
        guard wsCandidateIndex + 1 < candidateWebSocketURLs.count else { return }

        wsCandidateIndex += 1
        webSocketURL = candidateWebSocketURLs[wsCandidateIndex]

        #if DEBUG
        print("🔁 WS retry next candidate [\(wsCandidateIndex+1)/\(candidateWebSocketURLs.count)] ->", webSocketURL.absoluteString, "reason=", reason)
        #endif

        // IMPORTANT: keep token when retrying.
        let token = accessToken

        // Reset any in-flight connection before retry.
        readBuffer = ""
        isConnected = false
        isSubscribed = false
        currentRoomId = nil
        subscriptionId = nil

        disconnect(resetToken: false)
        connectInternal(accessToken: token, isRetry: true)
    }

    private var task: URLSessionWebSocketTask?
    private var receiveLoopTask: Task<Void, Never>?

    private var readBuffer: String = ""

    private var isConnected: Bool = false
    private var isSubscribed: Bool = false
    private var currentRoomId: Int?
    private var subscriptionId: String?
    private var accessToken: String = ""

    private var pingLoopTask: Task<Void, Never>?
    private var reconnectTask: Task<Void, Never>?
    private var reconnectAttempt: Int = 0

  

    deinit {
        disconnect()
    }

    
    func connect(accessToken: String) {
        connectInternal(accessToken: accessToken, isRetry: false)
    }

    private func connectInternal(accessToken: String, isRetry: Bool) {
        if case .connecting = state { return }
        if case .connected = state { return }
        if case .subscribed = state { return }

        let trimmedToken = accessToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedToken.isEmpty {
            fail("accessToken is empty")
            return
        }

        // ✅ Fresh connect: always start from the first candidate
        // ✅ Retry: keep current candidate index
        if !isRetry {
            wsCandidateIndex = 0
            webSocketURL = candidateWebSocketURLs.first ?? webSocketURL
        }

        self.accessToken = trimmedToken

        // ✅ Normalize scheme just in case something constructed https/http instead of wss/ws.
        webSocketURL = normalizeWebSocketURL(webSocketURL)

        print("SMTOP 연결", webSocketURL.absoluteString, "tokenLen=", trimmedToken.count)
        #if DEBUG
        print("📡 FINAL CONNECT URL =", webSocketURL.absoluteString)
        #endif

        DispatchQueue.main.async {
            self.state = .connecting
        }
        isConnected = false
        isSubscribed = false
        currentRoomId = nil
        subscriptionId = nil
        readBuffer = ""

        let session = URLSession(configuration: .default)

        // ✅ URLSessionWebSocketTask가 올바른 Upgrade 헤더를 구성하도록 protocols 파라미터를 사용
        // (Sec-WebSocket-Protocol을 직접 세팅하면 배포환경/프록시에서 200으로 떨어지는 케이스가 있음)
        let wsTask = session.webSocketTask(with: webSocketURL, protocols: ["v12.stomp"])
        self.task = wsTask

        #if DEBUG
        print("🧩 WS handshake url=", webSocketURL.absoluteString, "candidate=", "\(wsCandidateIndex+1)/\(candidateWebSocketURLs.count)")
        #endif

        wsTask.resume()

        // Start keep-alive ping loop (prevents some proxies from closing idle websockets)
        startPingLoop()

        startReceiveLoop()

        let connectFrame = stompFrame(
            command: "CONNECT",
            headers: [
                "accept-version": "1.2",
                "heart-beat": "10000,10000",
                "host": (self.webSocketURL.host ?? "localhost"),
                "Authorization": "Bearer \(trimmedToken)"
            ],
            body: nil
        )

        sendStomp(connectFrame) { [weak self] ok, err in
            guard let self else { return }
            if ok {
                // nothing
            } else {
                let msg = err ?? "unknown"
                self.fail("CONNECT send failed: \(msg)")
                if msg.localizedCaseInsensitiveContains("bad response") {
                    self.retryWithNextWebSocketURLIfPossible(reason: msg)
                }
            }
        }

        // If we never receive CONNECTED, surface an error instead of hanging forever.
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            guard let self else { return }
            if !self.isConnected {
                self.fail("WebSocket/STOMP CONNECTED timeout")
                self.retryWithNextWebSocketURLIfPossible(reason: "CONNECTED timeout")
            }
        }
    }

    
    func subscribe(roomId: Int) {
        guard isConnected else {
            fail("Not connected")
            return
        }

        if isSubscribed, currentRoomId == roomId { return }

        if isSubscribed, let sid = subscriptionId {
            let unsub = stompFrame(command: "UNSUBSCRIBE", headers: ["id": sid], body: nil)
            sendStomp(unsub, completion: nil)
            isSubscribed = false
            currentRoomId = nil
            subscriptionId = nil
        }

        let sid = "sub-\(UUID().uuidString)"
        let destination = "/topic/rooms/\(roomId)"

#if DEBUG
        print("🧭 SUBSCRIBE roomId=", roomId, "destination=", destination)
#endif

        let receiptId = "sub-receipt-\(UUID().uuidString)"
        let headers: [String: String] = [
            "id": sid,
            "destination": destination,
            "ack": "auto",
            // Ask server to confirm subscription
            "receipt": receiptId
        ]

#if DEBUG
        print("📨 SUBSCRIBE receipt=", receiptId)
#endif

        print("STOMP 연결띠 ->", destination)

        let frame = stompFrame(
            command: "SUBSCRIBE",
            headers: headers,
            body: nil
        )

        sendStomp(frame) { [weak self] ok, err in
            guard let self else { return }
            if ok {
#if DEBUG
                print("✅ SUBSCRIBE frame sent. currentRoomId will be set to", roomId)
#endif
                self.isSubscribed = true
                self.currentRoomId = roomId
                self.subscriptionId = sid
                DispatchQueue.main.async {
                    self.state = .subscribed(roomId: roomId)
                }
            } else {
                self.fail("SUBSCRIBE failed: \(err ?? "unknown")")
            }
        }
    }


    func sendMessage(roomId: Int, message: String) {
        guard isConnected else {
            fail("Not connected")
            return
        }

        // ✅ Prevent sending to a room we are not subscribed to.
        // This is the #1 reason messages appear only locally (optimistic UI) but never arrive on the other client.
        guard isSubscribed, currentRoomId == roomId else {
#if DEBUG
            print("❌ SEND blocked: not subscribed to this room. currentRoomId=", currentRoomId as Any, "targetRoomId=", roomId, "isSubscribed=", isSubscribed)
#endif
            fail("Not subscribed to room \(roomId)")
            return
        }

#if DEBUG
        print("🧭 SEND using roomId=", roomId, "currentRoomId=", currentRoomId as Any)
#endif

        let destination = "/app/chat/rooms/\(roomId)/send"

        let payload: [String: String] = ["message": message]
        let bodyData = (try? JSONSerialization.data(withJSONObject: payload, options: [])) ?? Data()
        let body = String(data: bodyData, encoding: .utf8) ?? "{}"

        let receiptId = "send-receipt-\(UUID().uuidString)"
        var headers: [String: String] = [
            "destination": destination,
            // Spring often likes an explicit charset
            "content-type": "application/json;charset=UTF-8",
            // Ask server to confirm the SEND was processed
            "receipt": receiptId
        ]

#if DEBUG
        print("📤 STOMP SEND ->", destination, "receipt=", receiptId, "body=", body)
#endif

        let frame = stompFrame(
            command: "SEND",
            headers: headers,
            body: body
        )

        sendStomp(frame) { [weak self] ok, err in
            guard let self else { return }
            if ok {
#if DEBUG
                print("✅ SEND frame sent (waiting RECEIPT if server supports it)")
#endif
            } else {
                self.fail("SEND failed: \(err ?? "unknown")")
            }
        }
    }

    func disconnect(resetToken: Bool = true) {
        pingLoopTask?.cancel()
        pingLoopTask = nil
        reconnectTask?.cancel()
        reconnectTask = nil
        reconnectAttempt = 0

        receiveLoopTask?.cancel()
        receiveLoopTask = nil

        if isConnected {
            let frame = stompFrame(command: "DISCONNECT", headers: ["receipt": "disc-\(UUID().uuidString)"], body: nil)
            sendStomp(frame, completion: nil)
        }
        #if DEBUG
        print("🛑 WS cancel")
        #endif
        task?.cancel(with: .goingAway, reason: nil)
        task = nil

        isConnected = false
        isSubscribed = false
        currentRoomId = nil
        subscriptionId = nil
        readBuffer = ""
        if resetToken {
            accessToken = ""
        }

        DispatchQueue.main.async {
            self.state = .disconnected
        }
    }

  

    private func startReceiveLoop() {
        receiveLoopTask?.cancel()
        receiveLoopTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                guard let task = self.task else { return }

                do {
                    let msg = try await task.receive()
                    switch msg {
                    case .string(let text):
                        self.handleIncoming(text)
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8) {
                            self.handleIncoming(text)
                        }
                    @unknown default:
                        break
                    }
                } catch {
                    if Task.isCancelled { return }
                    let msg = error.localizedDescription

                    // When the server/proxy closes the socket later, iOS often reports:
                    // "Socket is not connected".
                    // Treat it as a disconnect and attempt a reconnect.
                    self.fail("WebSocket receive error: \(msg)")

                    if msg.localizedCaseInsensitiveContains("bad response") {
                        self.retryWithNextWebSocketURLIfPossible(reason: msg)
                        return
                    }

                    // Reconnect on common disconnect signals
                    if msg.localizedCaseInsensitiveContains("socket is not connected") ||
                        msg.localizedCaseInsensitiveContains("cancelled") ||
                        msg.localizedCaseInsensitiveContains("closed") ||
                        msg.localizedCaseInsensitiveContains("timed out") {
                        self.scheduleReconnect(reason: msg)
                        return
                    }

                    // Fallback: also try reconnect once
                    self.scheduleReconnect(reason: msg)
                    return
                }
            }
        }
    }

    private func handleIncoming(_ chunk: String) {
        // ✅ 순수 WebSocket(STOMP) 스트림만 처리
        ingestStompStream(chunk)
    }

    private func ingestStompStream(_ stompChunk: String) {
        readBuffer.append(stompChunk)

        while let nulRange = readBuffer.range(of: "\u{0000}") {
            let frameText = String(readBuffer[..<nulRange.lowerBound])
            readBuffer.removeSubrange(..<nulRange.upperBound)

            let frame = parseFrame(frameText)
            handleFrame(frame)
        }
    }

    private func handleFrame(_ frame: StompFrame) {
        switch frame.command {
        case "CONNECTED":
            isConnected = true
            reconnectAttempt = 0
            print(" STOMP 연결띠오")
            DispatchQueue.main.async {
                self.state = .connected
            }

        case "MESSAGE":
#if DEBUG
            // Print destination + raw body for debugging
            let dest = frame.headers["destination"] ?? "(no destination)"
            print("📩 STOMP MESSAGE dest=", dest)
            print("🧭 MESSAGE currentRoomId=", currentRoomId as Any)
#endif
            guard let body = frame.body else {
#if DEBUG
                print("❌ STOMP MESSAGE has no body")
#endif
                return
            }

#if DEBUG
            print("📩 STOMP MESSAGE raw body=", body)
#endif

            guard let data = body.data(using: .utf8) else {
#if DEBUG
                print("❌ STOMP MESSAGE body not utf8")
#endif
                return
            }

            do {
                let decoder = JSONDecoder()
                // Backend often returns snake_case keys (e.g., message_id, created_at)
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded = try decoder.decode(IncomingMessage.self, from: data)
                DispatchQueue.main.async {
                    self.onMessage?(decoded)
                }
            } catch {
#if DEBUG
                print("❌ STOMP MESSAGE decode failed:", error.localizedDescription)
#endif
            }

        case "ERROR":
            print("에러 프레임=\(frame.headers) body=\(frame.body ?? "")")
            let msg = frame.headers["message"] ?? "STOMP ERROR"
            fail("\(msg)\n\(frame.body ?? "")")

        case "RECEIPT":
#if DEBUG
            let receipt = frame.headers["receipt-id"] ?? frame.headers["receipt"] ?? "(no id)"
            print("✅ STOMP RECEIPT received:", receipt)
#endif

        default:
            break
        }
    }



    private struct StompFrame {
        let command: String
        let headers: [String: String]
        let body: String?
    }

    private func stompFrame(command: String, headers: [String: String], body: String?) -> String {
        // STOMP frame format:
        // COMMAND\n
        // header1:value\n
        // header2:value\n
        // \n
        // <body (optional)>\u0000

        var hdrs = headers
        if let body {
            hdrs["content-length"] = String(body.utf8.count)
        }

        var frame = command + "\n"

        // Headers
        for (k, v) in hdrs {
            frame += "\(k):\(v)\n"
        }

        // Header/body delimiter (IMPORTANT)
        frame += "\n"

        // Body
        if let body {
            frame += body
        }

        // Frame terminator
        frame += "\u{0000}"
        return frame
    }

    private func parseFrame(_ text: String) -> StompFrame {
     
        let parts = text.components(separatedBy: "\n\n")
        let head = parts.first ?? ""
        let body = parts.count > 1 ? parts.dropFirst().joined(separator: "\n\n") : nil

        let headLines = head.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let command = headLines.first ?? ""

        var headers: [String: String] = [:]
        for line in headLines.dropFirst() {
            guard let idx = line.firstIndex(of: ":") else { continue }
            let k = String(line[..<idx])
            let v = String(line[line.index(after: idx)...])
            headers[k] = v
        }

        return StompFrame(command: command, headers: headers, body: body)
    }

    private func sendStomp(_ stompFrameText: String, completion: ((Bool, String?) -> Void)?) {
        // ✅ 순수 WebSocket(STOMP)만 사용
        sendRaw(stompFrameText, completion: completion)
    }

    private func sendRaw(_ text: String, completion: ((Bool, String?) -> Void)?) {
        guard let task else {
            completion?(false, "WebSocket task is nil")
            return
        }

        task.send(.string(text)) { error in
            if let error {
#if DEBUG
                print("❌ WS send error:", error.localizedDescription)
#endif
                completion?(false, error.localizedDescription)
            } else {
                completion?(true, nil)
            }
        }
    }

    // MARK: - Keep Alive / Reconnect

    private func normalizeWebSocketURL(_ url: URL) -> URL {
        // URLSessionWebSocketTask should use ws/wss schemes.
        // If someone accidentally passes http/https, convert it.
        guard let scheme = url.scheme?.lowercased() else { return url }
        if scheme == "wss" || scheme == "ws" { return url }

        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if scheme == "https" {
            comps?.scheme = "wss"
        } else if scheme == "http" {
            comps?.scheme = "ws"
        }
        return comps?.url ?? url
    }

    private func startPingLoop() {
        pingLoopTask?.cancel()
        pingLoopTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 15_000_000_000) // 15s
                if Task.isCancelled { return }
                guard let task = self.task else { return }

                // If we are not connected yet, skip ping.
                if !self.isConnected { continue }

                task.sendPing { [weak self] error in
                    guard let self else { return }
                    if let error {
#if DEBUG
                        print("❌ WS ping failed:", error.localizedDescription)
#endif
                        self.scheduleReconnect(reason: "ping failed: \(error.localizedDescription)")
                    } else {
#if DEBUG
                        print("🏓 WS ping/pong ok")
#endif
                    }
                }
            }
        }
    }

    private func scheduleReconnect(reason: String) {
        // Avoid stacking multiple reconnect tasks
        reconnectTask?.cancel()

        // If the view called disconnect() intentionally, do nothing.
        // (When task is nil and state is disconnected, we shouldn't reconnect.)
        if case .disconnected = state { return }

        reconnectAttempt += 1
        let attempt = reconnectAttempt

        // Exponential-ish backoff with a cap
        let delaySec = min(8.0, Double(1 + attempt))

#if DEBUG
        print("🔌 scheduleReconnect attempt=\(attempt) in \(delaySec)s reason=\(reason)")
#endif

        let token = self.accessToken

        reconnectTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: UInt64(delaySec * 1_000_000_000))
            if Task.isCancelled { return }

            // Reset current socket state, but keep token.
            self.disconnect(resetToken: false)

            // Use a retry connect so we keep the current candidate.
            self.connectInternal(accessToken: token, isRetry: true)
        }
    }

    private func fail(_ message: String) {
        print("에러:", message)
        DispatchQueue.main.async {
            self.state = .error(message)
        }
    }
}
