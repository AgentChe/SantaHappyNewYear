//
//  ChatsTableCell.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 28.10.2024.
//

import UIKit

final class ChatsTableCell: UITableViewCell {
    lazy var selectedContainer = makeSelectedContainer()
    lazy var contentContainer = makeContentContainer()
    lazy var dateLabel = makeLabel()
    lazy var messageLabel = makeLabel()
    
    private lazy var dateAttrs = TextAttributes()
        .textColor(Appearance.mono200.withAlphaComponent(0.4))
        .font(Fonts.SFProRounded.medium(size: 12.scale))
        .lineHeight(14.scale)
        .textAlignment(.left)
    private lazy var messageAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.SFProRounded.semiBold(size: 21.scale))
        .lineHeight(25.scale)
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ChatsTableCell {
    func setup(element: ChatsTableElement) {
        dateLabel.attributedText = element.date.attributed(with: dateAttrs)
        
        let messageHTML: NSAttributedString = {
            let message = element.chat.lastMessage.content
            
            let font = Fonts.SFProRounded.regular(size: 16.scale)
            let htmlWithStyle = "<span style=\"font-family: \(font.fontName); font-style: regular; font-size: \(font.pointSize); line-height: \(22.scale)px;\">\(message)</span>"
            
            guard let data = htmlWithStyle.data(using: .utf8) else { return message.attributed(with: messageAttrs) }
            
            let attributedString = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            guard let attributedString else { return message.attributed(with: messageAttrs) }
            
            return attributedString
        }()
        messageLabel.attributedText = messageHTML
    }
}

// MARK: Private
private extension ChatsTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ChatsTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            selectedContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            selectedContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            selectedContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.scale),
            selectedContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: selectedContainer.leadingAnchor, constant: 16.scale),
            contentContainer.trailingAnchor.constraint(equalTo: selectedContainer.trailingAnchor, constant: -16.scale),
            contentContainer.topAnchor.constraint(equalTo: selectedContainer.topAnchor, constant: 20.scale),
            contentContainer.bottomAnchor.constraint(equalTo: selectedContainer.bottomAnchor, constant: -20.scale)
        ])
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            messageLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4.scale),
            messageLabel.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatsTableCell {
    func makeSelectedContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono100.withAlphaComponent(0.9)
        view.layer.cornerRadius = 24.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.custom153.withAlphaComponent(0.4).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeContentContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        selectedContainer.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(view)
        return view
    }
}
