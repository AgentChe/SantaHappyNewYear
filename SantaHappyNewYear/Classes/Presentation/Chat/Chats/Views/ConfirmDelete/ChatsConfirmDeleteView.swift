//
//  ChatsConfirmDeleteView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 06.10.2025.
//

import UIKit

final class ChatsConfirmDeleteView: UIView {
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var textLabel = makeTextLabel()
    lazy var cancelButton = makeCancelButton()
    lazy var deleteButton = makeDeleteButton()
    
    private lazy var containerYConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ChatsConfirmDeleteView {
    func animateShow() {
        containerYConstraint.isActive = false
        containerYConstraint = container.centerYAnchor.constraint(equalTo: centerYAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0.6
            self?.layoutIfNeeded()
        })
    }
    
    func animateDismiss(completion: @escaping (() -> Void)) {
        containerYConstraint.isActive = false
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        containerYConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.dimmedView.alpha = 0
            self?.layoutIfNeeded()
        }, completion: { result in
            completion()
        })
    }
}

// MARK: Make constraints
private extension ChatsConfirmDeleteView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmedView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        containerYConstraint = container.topAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([
            containerYConstraint,
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 51.scale),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -51.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 22.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -22.scale),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 22.scale)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 22.scale),
            textLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -22.scale),
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.scale),
            textLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -80.scale)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            cancelButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale),
            cancelButton.heightAnchor.constraint(equalToConstant: 48.scale),
            cancelButton.widthAnchor.constraint(equalToConstant: 128.scale)
        ])
        
        NSLayoutConstraint.activate([
            deleteButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            deleteButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale),
            deleteButton.heightAnchor.constraint(equalToConstant: 48.scale),
            deleteButton.widthAnchor.constraint(equalToConstant: 128.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatsConfirmDeleteView {
    func makeDimmedView() -> UIView {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(integralRed: 245, green: 245, blue: 245)
        view.layer.cornerRadius = 40.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.SFProRounded.semiBold(size: 17.scale))
            .lineHeight(22.scale)
            .letterSpacing(-0.43.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Chats.ConfirmDelete.Title".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTextLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.SFProRounded.regular(size: 17.scale))
            .lineHeight(22.scale)
            .letterSpacing(-0.43.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Chats.ConfirmDelete.Text".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeCancelButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.SFProRounded.medium(size: 17.scale))
        
        let view = UIButton()
        view.layer.cornerRadius = 24.scale
        view.backgroundColor = UIColor(integralRed: 120, green: 120, blue: 128, alpha: 0.3)
        view.setAttributedTitle("Cancel".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeDeleteButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(UIColor(integralRed: 255, green: 56, blue: 60))
            .font(Fonts.SFProRounded.medium(size: 17.scale))
        
        let view = UIButton()
        view.layer.cornerRadius = 24.scale
        view.backgroundColor = UIColor(integralRed: 120, green: 120, blue: 128, alpha: 0.3)
        view.setAttributedTitle("Delete".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
