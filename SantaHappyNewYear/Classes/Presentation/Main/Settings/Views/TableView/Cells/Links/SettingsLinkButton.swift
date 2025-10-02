//
//  SettingsLinkButton.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import UIKit

final class SettingsLinkButton: UIButton {
    lazy var label = makeLabel()
    lazy var arrowView = makeArrowView()
    lazy var separator = makeSeparator()
    
    private let title: String
    private let withSeparator: Bool
    private let didTap: () -> Void
    
    init(title: String, withSeparator: Bool, didTap: @escaping () -> Void) {
        self.title = title
        self.withSeparator = withSeparator
        self.didTap = didTap
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension SettingsLinkButton {
    func initialize() {
        backgroundColor = UIColor.clear
        
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    @objc
    func tapped() {
        didTap()
    }
}

// MARK: Make constraints
private extension SettingsLinkButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 10.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 22.scale),
            arrowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            arrowView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        if let separator {
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
                separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
                separator.heightAnchor.constraint(equalToConstant: 1.scale),
                separator.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
}

// MARK: Lazy initialization
private extension SettingsLinkButton {
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.black)
            .font(Fonts.SFProRounded.regular(size: 17.scale))
            .lineHeight(22.scale)
            .letterSpacing(-0.43.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Settings.Arrow")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView? {
        guard withSeparator else { return nil }
        
        let view = UIView()
        view.backgroundColor = Appearance.custom230
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
