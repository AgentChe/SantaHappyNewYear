//
//  ChatView.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 26.10.2024.
//

import UIKit

final class ChatView: UIView {
    lazy var tableView = makeTableView()
    lazy var inputField = makeInputField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ChatView {
    func initialize() {
        backgroundColor = Appearance.custom245_236_229
    }
}

// MARK: Make constraints
private extension ChatView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputField.topAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            inputField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            inputField.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatView {
    func makeTableView() -> ChatTableView {
        let view = ChatTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeInputField() -> ChatInputField {
        let view = ChatInputField()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
