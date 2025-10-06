//
//  ChatsTableView.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 28.10.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatsTableView: UITableView {
    private lazy var elements = [ChatsTableElement]()
    
    private lazy var didSelectTrigger = PublishRelay<Chat>()
    private lazy var didDeleteTrigger = PublishRelay<Chat>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ChatsTableView {
    func setup(elements: [ChatsTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<Chat> {
        didSelectTrigger.asSignal()
    }
    
    var didDelete: Signal<Chat> {
        didDeleteTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension ChatsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: ChatsTableCell.self), for: indexPath) as! ChatsTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension ChatsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = elements[indexPath.row].chat
        didSelectTrigger.accept(chat)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            
            didDeleteTrigger.accept(elements[indexPath.row].chat)
            
            completion(true)
        }
        delete.image = UIImage(named: "Chats.Delete")
        delete.backgroundColor = Appearance.main200

        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

// MARK: Private
private extension ChatsTableView {
    func initialize() {
        contentInset = UIEdgeInsets(t: 8.scale, b: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -8.scale), animated: false)
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        backgroundColor = UIColor.clear
        
        register(ChatsTableCell.self, forCellReuseIdentifier: String(describing: ChatsTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
