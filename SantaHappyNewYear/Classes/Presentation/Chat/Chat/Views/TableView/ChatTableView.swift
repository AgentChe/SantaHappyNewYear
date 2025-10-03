//
//  ChatTableView.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 29.10.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatTableView: UITableView {
    private lazy var elements = [ChatTableElement]()
    
    private lazy var didScrollToTopTrigger = PublishRelay<Void>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ChatTableView {
    func insert(elements: [ChatTableElement]) {
        self.elements.insert(contentsOf: elements, at: 0)
        
        reloadData()
        
        if self.elements.count == elements.count {
            let index = IndexPath(row: self.elements.count - 1, section: 0)
            scrollToRow(at: index, at: .bottom, animated: false)
        } else {
            let index = self.elements.count - elements.count
            if elements.indices.contains(index) {
                let indexPath = IndexPath(row: index, section: 0)
                scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    func add(elements: [ChatTableElement]) {
        self.elements.append(contentsOf: elements)
        
        reloadData()
        
        if !self.elements.isEmpty {
            let index = IndexPath(row: self.elements.count - 1, section: 0)
            scrollToRow(at: index, at: .bottom, animated: false)
        }
    }
    
    func remove(answer messageId: String) {
        self.elements.removeAll(where: { element -> Bool in
            switch element {
            case .answer(let element):
                return element.message.messageId == messageId
            default:
                return false
            }
        })
        
        reloadData()
    }
    
    func loading(waitAnswer: Bool) {
        if waitAnswer {
            elements.append(.loading)
        } else {
            elements.removeAll(where: { element -> Bool in
                switch element {
                case .loading:
                    return true
                default:
                    return false
                }
            })
        }
        
        reloadData()
    }
    
    var didScrollToTop: Signal<Void> {
        didScrollToTopTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension ChatTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .questionText(let question):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ChatQuestionTextCell.self), for: indexPath) as! ChatQuestionTextCell
            cell.setup(question: question)
            return cell
        case .loading:
            return dequeueReusableCell(withIdentifier: String(describing: ChatLoadingCell.self), for: indexPath)
        case .answer(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ChatAnswerCell.self), for: indexPath) as! ChatAnswerCell
            cell.setup(text: element.message.content)
            return cell
        case .historyAnswer(let message):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ChatAnswerCell.self), for: indexPath) as! ChatAnswerCell
            cell.setup(text: message.content)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension ChatTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            didScrollToTopTrigger.accept(Void())
        }
        
        if let loadingCell = cell as? ChatLoadingCell {
            loadingCell.startAnimating()
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let loadingCell = cell as? ChatLoadingCell {
            loadingCell.stopAnimating()
        }
    }
}

// MARK: Private
private extension ChatTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        contentInset = UIEdgeInsets(vertical: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        
        register(ChatQuestionTextCell.self, forCellReuseIdentifier: String(describing: ChatQuestionTextCell.self))
        register(ChatLoadingCell.self, forCellReuseIdentifier: String(describing: ChatLoadingCell.self))
        register(ChatAnswerCell.self, forCellReuseIdentifier: String(describing: ChatAnswerCell.self))
        
        dataSource = self
        delegate = self
    }
}
