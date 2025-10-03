//
//  ChatViewController.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 26.10.2024.
//

import UIKit
import RxSwift
import RxCocoa
import Toast_Swift

final class ChatViewController: UIViewController {
    private lazy var mainView = ChatView()
    
    private lazy var viewModel = ChatViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private let chat: Chat?
    
    private init(chat: Chat?) {
        self.chat = chat
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.open(error: error)
        }
        
        let didSendMessage = mainView.inputField
            .sendButton.rx.tap
            .withLatestFrom(mainView.inputField.textField.rx.text)
            .compactMap { message -> String? in
                guard let message, !message.isEmpty else { return nil }
                return message
            }
            .asSignal(onErrorSignalWith: .never())
        
        let output = viewModel.configure(input: ChatViewModel.Input(
            chat: chat,
            didScrollToTop: mainView.tableView.didScrollToTop,
            didSendMessage: didSendMessage
        ))
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension ChatViewController {
    static func make(chat: Chat? = nil) -> ChatViewController {
        let vc = ChatViewController(chat: chat)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "Chat.Title".localized
        return vc
    }
}

// MARK: Private
private extension ChatViewController {
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make(error: error) {
                    observe.onNext(())
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
    
    func action(_ action: ChatViewModel.Action) {
        switch action {
        case .insertPage(let elements):
            mainView.tableView.insert(elements: elements)
        case .add(let elements):
            mainView.tableView.add(elements: elements)
        case .startWaiting:
            mainView.tableView.loading(waitAnswer: true)
        case .stopWaiting:
            mainView.tableView.loading(waitAnswer: false)
        case .clearInput:
            mainView.inputField.textField.text = ""
        case .lockSendMessage(let lock):
            mainView.inputField.sendButton.isEnabled = !lock
        }
    }
}
