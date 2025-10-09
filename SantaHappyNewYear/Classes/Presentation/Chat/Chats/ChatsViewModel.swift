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
        case openChat(Chat?)
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
        let didTapWriteMessage: Signal<Void>
        let didScrollToBottom: Signal<Void>
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
                didTapDelete: input.didTapDelete,
                didTapWriteMessage: input.didTapWriteMessage
            ),
            elements: makeElements(
                didScrollToBottom: input.didScrollToBottom,
                didConfirmDelete: input.didConfirmDelete
            ),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension ChatsViewModel {
    func makeAction(
        selectChat: Signal<Chat>,
        didTapDelete: Signal<Chat>,
        didTapWriteMessage: Signal<Void>
    ) -> Driver<Action> {
        let openChat = Signal
            .merge(
                selectChat.map { chat -> Chat? in chat },
                didTapWriteMessage.map { void -> Chat? in nil }
            )
            .map { Action.openChat($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let requestConfirmDelete = didTapDelete
            .map { Action.requestConfirmDelete($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(openChat, requestConfirmDelete)
    }
    
    func makeElements(
        didScrollToBottom: Signal<Void>,
        didConfirmDelete: Signal<Chat>
    ) -> Driver<[ChatsTableElement]> {
        var lastPageInfo: PageInfo?
        
        func fetch(page: Int) -> Driver<Page<[Chat]>> {
            chatManager
                .chats()
                .trackActivity(page == 1 ? activity : RxActivityIndicator())
                .asDriver(onErrorJustReturn: nil)
                .compactMap { $0 }
                .do(onNext: { page in
                    lastPageInfo = page.info
                })
        }
        
        let firstPage = fetch(page: 1)
        
        let chats = firstPage
            .flatMapLatest { firstPage -> Driver<[Chat]> in
                let downloadPage = didScrollToBottom
                    .asDriver(onErrorDriveWith: .never())
                    .compactMap { lastPageInfo }
                    .filter { ($0.nextPage <= $0.total) && ($0.current != $0.total) }
                    .flatMapFirst { lastPageInfo -> Driver<Page<[Chat]>> in
                        fetch(page: lastPageInfo.nextPage)
                    }
                    .startWith(firstPage)
                
                enum Action {
                    case page(Page<[Chat]>)
                    case delete(String)
                }
                
                let delete = didConfirmDelete
                    .flatMapLatest { [weak self] chat -> Driver<Action> in
                        guard let self else { return .never() }
                        
                        return chatManager
                            .deleteChat(id: chat.id)
                            .asDriver(onErrorDriveWith: .never())
                            .map { Action.delete(chat.id) }
                    }
                
                let action = Driver
                    .merge(
                        downloadPage.map { Action.page($0) },
                        delete
                    )
                
                return action
                    .scan([]) { chats, action -> [Chat] in
                        switch action {
                        case .page(let page):
                            return page.info.current == 1 ? page.elements : (chats + page.elements)
                        case .delete(let id):
                            var result = chats
                            result.removeAll(where: { $0.id == id })
                            return result
                        }
                    }
            }
        
        return chats
            .map { $0.map { ChatsTableElement(chat: $0) } }
    }
}
