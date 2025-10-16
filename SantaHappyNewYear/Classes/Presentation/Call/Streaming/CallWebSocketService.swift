//
//  CallWebSocketService.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 09.10.2025.
//

import RxSwift
import RxCocoa

final class CallWebSocketService: NSObject {
    enum AgentState {
        case listening, speaking
    }
    
    enum ConnectionState {
        case connecting, open, closed(Error?)
    }
    
    private struct WSConfig {
        let url: URL
        let accessToken: String
        let anonymousId: String
        let internalId: String
    }
    
    private let cfg: WSConfig
    private var session: URLSession!
    private var task: URLSessionWebSocketTask?
    private let queue = DispatchQueue(label: "ws.call.queue")
    private var pingTimer: DispatchSourceTimer?
    
    private let agentStateSubject = PublishSubject<AgentState>()
    private let audioSubject = PublishSubject<Data>()
    private let connStateSubject = BehaviorSubject<ConnectionState>(value: .closed(nil))
    
    override init() {
        cfg = WSConfig(
            url: URL(string: GlobalDefinitions.wssDomain + "/api/v1/ws/call")!,
            accessToken: GlobalDefinitions.apiKey,
            anonymousId: SessionManager().anonymousId,
            internalId: SessionManager().internalId
        )
        
        super.init()
        
        let conf = URLSessionConfiguration.default
        conf.waitsForConnectivity = true
        session = URLSession(configuration: conf, delegate: self, delegateQueue: nil)
    }
}

// MARK: Public
extension CallWebSocketService {
    func connect() {
        queue.async { [weak self] in
            guard let self else { return }
            
            if case .open = (try? connStateSubject.value()) ?? .closed(nil) {
                return
            }
            
            var request = URLRequest(url: cfg.url)
            request.timeoutInterval = 30
            request.addValue(cfg.accessToken, forHTTPHeaderField: "Access-Token")
            request.addValue(cfg.anonymousId, forHTTPHeaderField: "X-Anonymous-Id")
            request.addValue(cfg.internalId, forHTTPHeaderField: "X-Internal-Id")
            
            connStateSubject.onNext(.connecting)
            
            let task = session.webSocketTask(with: request)
            self.task = task
            task.resume()
            
            listen()
            startPing()
        }
    }
    
    func disconnect() {
        queue.async { [weak self] in
            guard let self else { return }
            
            stopPing()
            task?.cancel(with: .normalClosure, reason: nil)
            task = nil
            connStateSubject.onNext(.closed(nil))
        }
    }
    
    func send(message: String, status: String? = nil) {
        let body: [String: Any] = {
                    var b: [String: Any] = ["message": message]
                    if let status { b["status"] = status }
                    return b
                }()
        
        guard let data = try? JSONSerialization.data(withJSONObject: body, options: []) else { return }
        
        let text = String(data: data, encoding: .utf8) ?? ""
        
        queue.async { [weak self] in
            guard let self, let task else { return }
            
            task.send(.string(text)) { _ in }
        }
    }
    
    var agentState: Signal<AgentState> {
        agentStateSubject.asSignal(onErrorSignalWith: .never())
    }
    
    var audioChunks: Signal<Data> {
        audioSubject.asSignal(onErrorSignalWith: .never())
    }
    
    var connectionState: Signal<ConnectionState> {
        connStateSubject.asSignal(onErrorSignalWith: .never())
    }
}

// MARK: URLSessionWebSocketDelegate
extension CallWebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        connStateSubject.onNext(.open)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        connStateSubject.onNext(.closed(nil))
    }
}

// MARK: Private
private extension CallWebSocketService {
    struct Envelope: Decodable {
        struct Body: Decodable {
            let status: String?
        }
        
        let body: Body?
        let error: String?
    }
    
    func listen() {
        task?.receive { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .failure(let error):
                connStateSubject.onNext(.closed(error))
            case .success(let message):
                switch message {
                case .string(let text):
                    handleText(text)
                case .data(let data):
                    audioSubject.onNext(data)
                @unknown default:
                    break
                }
                listen()
            }
        }
    }
    
    func handleText(_ text: String) {
        if let data = text.data(using: .utf8),
           let env = try? JSONDecoder().decode(Envelope.self, from: data) {
            if env.error != nil { return }
            
            switch env.body?.status?.lowercased() {
            case "listening":
                agentStateSubject.onNext(.listening)
            case "speaking":
                agentStateSubject.onNext(.speaking)
            default:
                break
            }
        }
    }
    
    func startPing() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + 10, repeating: 10)
        timer.setEventHandler { [weak self] in
            self?.task?.sendPing { _ in }
        }
        timer.resume()
        pingTimer = timer
    }
    
    func stopPing() {
        pingTimer?.cancel()
        pingTimer = nil
    }
}
