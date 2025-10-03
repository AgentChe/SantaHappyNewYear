//
//  ChatViewModel.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 26.10.2024.
//

import RxSwift
import RxCocoa

final class ChatViewModel {
    enum Action {
        case insertPage([ChatTableElement])
        case add([ChatTableElement])
        case startWaiting
        case stopWaiting
        case clearInput
        case lockSendMessage(Bool)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?

    private lazy var chatManager = ChatManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension ChatViewModel {
    struct Input {
        let chat: Chat?
        let didScrollToTop: Signal<Void>
        let didSendMessage: Signal<String>
    }
    
    struct Output {
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        let mode = makeMode(chat: input.chat)
        let chatId = makeChatId(mode: mode)
        
        return Output(
            action: makeAction(
                mode: mode,
                chatId: chatId,
                didSendMessage: input.didSendMessage,
                didScrollToTop: input.didScrollToTop
            )
        )
    }
}

// MARK: Private
private extension ChatViewModel {
    enum Mode {
        case newChat, history(Chat)
    }
    
    func makeMode(chat: Chat?) -> Driver<Mode> {
        .deferred {
            guard let chat else { return .just(.newChat) }
            return .just(.history(chat))
        }
    }
    
    func makeAction(
        mode: Driver<Mode>,
        chatId: Driver<String>,
        didSendMessage: Signal<String>,
        didScrollToTop: Signal<Void>
    ) -> Driver<Action> {
        let clearInput = Driver
            .merge(
                mode.map { _ in Action.clearInput },
                didSendMessage.map { _ in Action.clearInput }.asDriver(onErrorDriveWith: .never())
            )
        
        let updateChat = mode
            .flatMapLatest { [weak self] _ -> Driver<Action> in
                guard let self else { return .never() }
                
                let sendMessageResponse = makeSendMessageResponse(
                    chatId: chatId,
                    didSendMessage: didSendMessage
                )
                
                let addQuestionInTable = sendMessageResponse
                    .compactMap { response -> Action? in
                        guard let response else { return nil }
                        
                        var elements = [ChatTableElement]()
                        
                        elements.append(.questionText(response.message.content))
                        
                        return .add(elements)
                    }
                
                let answerMessageResponse = makeAnswer(
                    runner: sendMessageResponse.compactMap { $0?.runner },
                    chatId: chatId
                )
                
                let addAnswerInTable = answerMessageResponse
                    .compactMap { response -> Action? in
                        guard let response, let message = response.message else { return nil }
                        
                        let element = ChatTableAnswerElement(runner: response.runner, message: message)
                        return .add([.answer(element)])
                    }
                
                let loading = Driver<Bool>
                    .merge(
                        sendMessageResponse.compactMap { $0 == nil ? nil : true },
                        answerMessageResponse.map { _ in false }
                    )
                
                let waiting = loading
                    .map { $0 ? Action.startWaiting : Action.stopWaiting }
                
                let lockSendMessage = loading
                    .map { Action.lockSendMessage($0) }
                
                let historyPage = makeHistoryPage(
                    mode: mode,
                    didScrollToTop: didScrollToTop,
                    chatId: chatId
                )
                
                let historyElements = historyPage
                    .map { $0.messages }
                    .map { messages -> [ChatTableElement] in
                        var elements = [ChatTableElement]()
                        
                        messages.reversed().forEach { message in
                            switch message.role {
                            case .user:
                                elements.append(.questionText(message.content))
                            case .assistant:
                                elements.append(.historyAnswer(message))
                            }
                        }
                        
                        return elements
                    }
                    .map { Action.insertPage($0) }
                
                return Driver
                    .merge(addQuestionInTable, addAnswerInTable, waiting, lockSendMessage, historyElements)
            }
        
        return Driver
            .merge(clearInput, updateChat)
    }
    
    func makeAnswer(runner: Driver<ChatMessageRunner>, chatId: Driver<String>) -> Driver<CheckMessageCompleteResponse?> {
        runner
            .withLatestFrom(chatId) { ($0.id, $1) }
            .delay(DispatchTimeInterval.seconds(2))
            .flatMapLatest { [weak self] args -> Driver<CheckMessageCompleteResponse?> in
                guard let self else { return .never() }
                
                let (runnerId, id) = args
                
                return chatManager
                    .checkMessageComplete(chatId: id, runnerId: runnerId)
                    .asDriver(onErrorJustReturn: nil)
                    .flatMap { [weak self] response -> Driver<CheckMessageCompleteResponse?> in
                        guard let self, let response else { return .just(nil) }
                        
                        return response.runner.isComplete ? .just(response) : makeAnswer(runner: runner, chatId: chatId)
                    }
            }
    }
    
    func makeSendMessageResponse(
        chatId: Driver<String>,
        didSendMessage: Signal<String>
    ) -> Driver<SendMessageResponse?> {
        didSendMessage
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(chatId) { ($0, $1) }
            .flatMapLatest { [weak self] message, chatId -> Driver<SendMessageResponse?> in
                guard let self else { return .never() }
                
                return chatManager
                    .send(image: nil, message: message, chatId: chatId)
                    .asDriver(onErrorJustReturn: nil)
            }
    }
    
    func makeChatId(mode: Driver<Mode>) -> Driver<String> {
        mode
            .flatMapLatest { [weak self] mode -> Driver<String> in
                guard let self else { return .never() }
                
                func source() -> Single<String> {
                    switch mode {
                    case .newChat:
                        return self.chatManager
                            .createChat()
                            .map { chatId -> String in
                                guard let chatId else { throw ContentError(.notContent) }
                                return chatId
                            }
                    case .history(let chat):
                        return .just(chat.id)
                    }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else { return .empty() }
                    return tryAgain
                }
                
                return observableRetrySingle
                    .retry(
                        source: { source() },
                        trigger: { trigger(error: $0) }
                    )
                    .asDriver(onErrorDriveWith: .never())
            }
    }
    
    func makeHistoryPage(mode: Driver<Mode>, didScrollToTop: Signal<Void>, chatId: Driver<String>) -> Driver<ChatMessagesPage> {
        chatId
            .withLatestFrom(mode) { ($0, $1) }
            .flatMapLatest { [weak self] args -> Driver<ChatMessagesPage> in
                let (chatId, mode) = args
                
                guard let self, mode.isHistory else { return .never() }
                
                var lastPage: ChatMessagesPage?
                
                func fetch(page: Int) -> Driver<ChatMessagesPage> {
                    chatManager
                        .messagesPage(chatId: chatId, page: page)
                        .compactMap { $0 }
                        .asDriver(onErrorDriveWith: .never())
                        .do(onNext: { page in
                            lastPage = page
                        })
                }
                
                let firstPage = fetch(page: 1)
                
                return firstPage
                    .flatMapLatest { firstPage -> Driver<ChatMessagesPage> in
                        didScrollToTop
                            .compactMap { lastPage }
                            .filter { (($0.page.current + 1) <= $0.page.total) && ($0.page.current != $0.page.total) }
                            .flatMapFirst { lastPage -> Driver<ChatMessagesPage> in
                                fetch(page: lastPage.page.current + 1)
                            }
                            .startWith(firstPage)
                    }
            }
    }
}

// MARK: Additional
private extension ChatViewModel.Mode {
    var isHistory: Bool {
        switch self {
        case .history:
            return true
        case .newChat:
            return false
        }
    }
}
