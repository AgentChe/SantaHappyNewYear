//
//  ChatsViewModel.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 26.10.2024.
//

import RxSwift
import RxCocoa

final class ChatsViewModel {
    enum Action {
        case openChat(Chat)
    }
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var chatManager = ChatManager()
}

// MARK: Public
extension ChatsViewModel {
    struct Input {
        let didSelectChat: Signal<Chat>
    }
    
    struct Output {
        let action: Driver<Action>
        let elements: Driver<[ChatsTableElement]>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(selectChat: input.didSelectChat),
            elements: makeElements(),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension ChatsViewModel {
    func makeAction(selectChat: Signal<Chat>) -> Driver<Action> {
        let openChat = selectChat
            .map { Action.openChat($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(openChat)
    }
    
    func makeElements() -> Driver<[ChatsTableElement]> {
        chatManager
            .chats()
            .trackActivity(activity)
            .asDriver(onErrorJustReturn: [])
            .map { $0.map { ChatsTableElement(chat: $0) } }
    }
}
