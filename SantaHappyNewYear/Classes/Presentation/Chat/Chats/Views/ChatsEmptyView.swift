//
//  ChatsEmptyView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 08.10.2025.
//

import UIKit

final class ChatsEmptyView: UIView {
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var textLabel = makeTextLabel()
    lazy var writeMessageButton = makeWriteMessageButton()
    
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
private extension ChatsEmptyView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension ChatsEmptyView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 173.scale),
            imageView.heightAnchor.constraint(equalToConstant: 173.scale),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 193.scale)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.scale),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80.scale)
        ])
        
        NSLayoutConstraint.activate([
            writeMessageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            writeMessageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            writeMessageButton.heightAnchor.constraint(equalToConstant: 60.scale),
            writeMessageButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatsEmptyView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Chats.Empty")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.PlayfairDisplay.bold(size: 23.scale))
            .lineHeight(31.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Chats.Empty.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTextLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.SFProRounded.regular(size: 17.scale))
            .lineHeight(22.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Chats.Empty.Text".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeWriteMessageButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.SFProRounded.medium(size: 17.scale))
        
        let view = UIButton()
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = 30.scale
        view.setAttributedTitle("Chats.Empty.Button".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
