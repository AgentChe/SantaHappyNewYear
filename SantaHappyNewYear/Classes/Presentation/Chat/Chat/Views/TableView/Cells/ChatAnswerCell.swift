//
//  ChatAnswerCell.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 29.10.2024.
//

import UIKit

final class ChatAnswerCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var label = makeLabel()
    lazy var circle1View = makeCircleView(cornerRadius: 6.scale)
    lazy var circle2View = makeCircleView(cornerRadius: 4.scale)
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.main200)
        .font(Fonts.SFProRounded.medium(size: 17.scale))
        .lineHeight(20.scale)
        .textAlignment(.left)
    
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
extension ChatAnswerCell {
    func setup(text: String) {
        let html: NSAttributedString = {
            let font = Fonts.SFProRounded.medium(size: 17.scale)
            let htmlWithStyle = "<span style=\"font-family: \(font.fontName); font-style: medium; font-size: \(font.pointSize); line-height: \(20.scale)px; color:#F5ECE5;\">\(text)</span>"
            
            guard let data = htmlWithStyle.data(using: .utf8) else { return text.attributed(with: attrs) }
            
            let attributedString = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            guard let attributedString else { return text.attributed(with: attrs) }
            
            return attributedString
        }()
        label.attributedText = html
    }
}

// MARK: Private
private extension ChatAnswerCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ChatAnswerCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -21.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            circle1View.widthAnchor.constraint(equalToConstant: 12.scale),
            circle1View.heightAnchor.constraint(equalToConstant: 12.scale),
            circle1View.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            circle1View.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9.scale)
        ])
        
        NSLayoutConstraint.activate([
            circle2View.widthAnchor.constraint(equalToConstant: 8.scale),
            circle2View.heightAnchor.constraint(equalToConstant: 8.scale),
            circle2View.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.scale),
            circle2View.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatAnswerCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = 24.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeCircleView(cornerRadius: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
