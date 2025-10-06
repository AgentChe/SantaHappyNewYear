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
        case requestConfirmDelete(Chat)
    }
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var chatManager = ChatManager()
}

// MARK: Public
extension ChatsViewModel {
    struct Input {
        let didSelectChat: Signal<Chat>
        let didTapDelete: Signal<Chat>
        let didConfirmDelete: Signal<Chat>
    }
    
    struct Output {
        let action: Driver<Action>
        let elements: Driver<[ChatsTableElement]>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            action: makeAction(
                selectChat: input.didSelectChat,
                didTapDelete: input.didTapDelete
            ),
            elements: makeElements(didConfirmDelete: input.didConfirmDelete),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension ChatsViewModel {
    func makeAction(
        selectChat: Signal<Chat>,
        didTapDelete: Signal<Chat>
    ) -> Driver<Action> {
        let openChat = selectChat
            .map { Action.openChat($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let requestConfirmDelete = didTapDelete
            .map { Action.requestConfirmDelete($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(openChat, requestConfirmDelete)
    }
    
    func makeElements(didConfirmDelete: Signal<Chat>) -> Driver<[ChatsTableElement]> {
        let initialChats = chatManager
            .chats()
            .trackActivity(activity)
            .asDriver(onErrorJustReturn: [])
        
        let chats = initialChats
            .flatMapLatest { initialChats -> Driver<[Chat]> in
                enum Action {
                    case delete(Chat)
                }
                
                let delete = didConfirmDelete
                    .flatMapLatest { [weak self] chat -> Driver<Action> in
                        guard let self else { return .never() }
                        
                        return chatManager
                            .deleteChat(id: chat.id)
                            .asDriver(onErrorDriveWith: .never())
                            .map { Action.delete(chat) }
                    }
                
                return delete
                    .scan(initialChats) { chats, action -> [Chat] in
                        switch action {
                        case .delete(let chat):
                            var result = chats
                            result.removeAll(where: { $0.id == chat.id })
                            return result
                        }
                    }
                    .startWith(initialChats)
            }
        
        return chats
            .map { $0.map { ChatsTableElement(chat: $0) } }
    }
}
