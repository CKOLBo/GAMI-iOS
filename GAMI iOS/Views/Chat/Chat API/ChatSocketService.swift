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
        let createdAt: String
        let senderId: Int
        let senderName: String
    }

    

    @Published private(set) var state: ConnectionState = .disconnected



    var onMessage: ((IncomingMessage) -> Void)?

    

    init(webSocketURL: URL = URL(string: "wss://port-0-gami-server-mj0rdvda8d11523e.sel3.cloudtype.app/ws/websocket")!) {
        self.webSocketURL = webSocketURL
    }

   

    private let webSocketURL: URL

    private var task: URLSessionWebSocketTask?
    private var receiveLoopTask: Task<Void, Never>?

    private var readBuffer: String = ""

    private var isConnected: Bool = false
    private var isSubscribed: Bool = false
    private var currentRoomId: Int?
    private var subscriptionId: String?
    private var accessToken: String = ""

  

    deinit {
        disconnect()
    }

    
    func connect(accessToken: String) {
        if case .connecting = state { return }
        if case .connected = state { return }
        if case .subscribed = state { return }

        self.accessToken = accessToken
        print("SMTOP 연결", webSocketURL.absoluteString, "tokenLen=", accessToken.count)

        state = .connecting
        isConnected = false
        isSubscribed = false
        currentRoomId = nil
        subscriptionId = nil
        readBuffer = ""

        let session = URLSession(configuration: .default)
        let wsTask = session.webSocketTask(with: webSocketURL)
        self.task = wsTask
        wsTask.resume()

        
        startReceiveLoop()

  
        let connectFrame = stompFrame(
            command: "CONNECT",
            headers: [
                "accept-version": "1.2",
                "heart-beat": "10000,10000",
                "Authorization": "Bearer \(accessToken)"
            ],
            body: nil
        )

        sendRaw(connectFrame) { [weak self] ok, err in
            guard let self else { return }
            if ok {
               
            } else {
                self.fail("CONNECT send failed: \(err ?? "unknown")")
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
            sendRaw(unsub, completion: nil)
            isSubscribed = false
            currentRoomId = nil
            subscriptionId = nil
        }

        let sid = "sub-\(UUID().uuidString)"
        let destination = "/topic/rooms/\(roomId)"

        var headers: [String: String] = [
            "id": sid,
            "destination": destination,
            "ack": "auto"
        ]

        print("STOMP 연결띠 ->", destination)

        let frame = stompFrame(
            command: "SUBSCRIBE",
            headers: headers,
            body: nil
        )

        sendRaw(frame) { [weak self] ok, err in
            guard let self else { return }
            if ok {
                self.isSubscribed = true
                self.currentRoomId = roomId
                self.subscriptionId = sid
                self.state = .subscribed(roomId: roomId)
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

      
        let destination = "/app/chat/rooms/\(roomId)/send"

      
        let payload: [String: String] = ["message": message]
        let bodyData = (try? JSONSerialization.data(withJSONObject: payload, options: [])) ?? Data()
        let body = String(data: bodyData, encoding: .utf8) ?? "{}"

        var headers: [String: String] = [
            "destination": destination,
            "content-type": "application/json"
        ]

        print(" STOMP 보내기 ->", destination, "body=", body)

        let frame = stompFrame(
            command: "SEND",
            headers: headers,
            body: body
        )

        sendRaw(frame) { [weak self] ok, err in
            guard let self else { return }
            if !ok {
                self.fail("SEND failed: \(err ?? "unknown")")
            }
        }
    }

    func disconnect() {
        receiveLoopTask?.cancel()
        receiveLoopTask = nil

        if isConnected {
            let frame = stompFrame(command: "DISCONNECT", headers: ["receipt": "disc-\(UUID().uuidString)"], body: nil)
            sendRaw(frame, completion: nil)
        }

        task?.cancel(with: .goingAway, reason: nil)
        task = nil

        isConnected = false
        isSubscribed = false
        currentRoomId = nil
        subscriptionId = nil
        readBuffer = ""
        accessToken = ""

        state = .disconnected
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
                    self.fail("WebSocket receive error: \(error.localizedDescription)")
                    return
                }
            }
        }
    }

    private func handleIncoming(_ chunk: String) {
        readBuffer.append(chunk)

      
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
            print(" STOMP 연결띠오")
            DispatchQueue.main.async {
                self.state = .connected
            }

        case "MESSAGE":
            print("바디렬에 연결=\(frame.body ?? "")")
      
            if let body = frame.body, let data = body.data(using: .utf8) {
                if let decoded = try? JSONDecoder().decode(IncomingMessage.self, from: data) {
                    DispatchQueue.main.async {
                        self.onMessage?(decoded)
                    }
                } else {
                   
                    print("❌ STOMP MESSAGE decode failed. body=\(body)")
                }
            }

        case "ERROR":
            print("에러 프레임=\(frame.headers) body=\(frame.body ?? "")")
            let msg = frame.headers["message"] ?? "STOMP ERROR"
            fail("\(msg)\n\(frame.body ?? "")")

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
        var lines: [String] = []
        lines.append(command)

        var hdrs = headers
        if let body {
           
            hdrs["content-length"] = String(body.utf8.count)
        }

        for (k, v) in hdrs {
            lines.append("\(k):\(v)")
        }
        lines.append("")

        var frame = lines.joined(separator: "\n")
        if let body {
            frame += body
        }
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


    private func sendRaw(_ text: String, completion: ((Bool, String?) -> Void)?) {
        guard let task else {
            completion?(false, "WebSocket task is nil")
            return
        }

        task.send(.string(text)) { error in
            if let error {
                completion?(false, error.localizedDescription)
            } else {
                completion?(true, nil)
            }
        }
    }

    private func fail(_ message: String) {
        print("에러:", message)
        DispatchQueue.main.async {
            self.state = .error(message)
        }
    }
}
