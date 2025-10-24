//
//  CanSpeakView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 24.10.2025.
//

import UIKit

final class CanSpeakView: UIView {
    lazy var label = makeLabel()
    
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
private extension CanSpeakView {
    func initialize() {
        backgroundColor = Appearance.mono100.withAlphaComponent(0.4)
        layer.borderColor = Appearance.mono100.cgColor
        layer.borderWidth = 1.scale
        layer.cornerRadius = 18.scale
        layer.masksToBounds = true
    }
}

// MARK: Make constraints
private extension CanSpeakView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CanSpeakView {
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.SFProRounded.medium(size: 17.scale))
            .lineHeight(20.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "VideoCall.CanSpeak".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
