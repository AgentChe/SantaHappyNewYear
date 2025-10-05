//
//  HomeActionsView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 05.10.2025.
//

import UIKit

final class HomeActionsView: UIView {
    lazy var textLabel = makeTextLabel()
    lazy var callSantaButton = makeCallSantaButton()
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
private extension HomeActionsView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension HomeActionsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80.scale)
        ])
        
        NSLayoutConstraint.activate([
            callSantaButton.widthAnchor.constraint(equalToConstant: 175.scale),
            callSantaButton.heightAnchor.constraint(equalToConstant: 60.scale),
            callSantaButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -6.scale),
            callSantaButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            writeMessageButton.widthAnchor.constraint(equalToConstant: 175.scale),
            writeMessageButton.heightAnchor.constraint(equalToConstant: 60.scale),
            writeMessageButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 6.scale),
            writeMessageButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeActionsView {
    func makeTextLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.main100)
            .font(Fonts.PlayfairDisplay.bold(size: 36.scale))
            .lineHeight(48.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 2
        view.attributedText = "Home.Text".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCallSantaButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.SFProRounded.medium(size: 17.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Home.CallSanta".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = 30.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeWriteMessageButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.SFProRounded.medium(size: 17.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Home.WriteMessage".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = 30.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
