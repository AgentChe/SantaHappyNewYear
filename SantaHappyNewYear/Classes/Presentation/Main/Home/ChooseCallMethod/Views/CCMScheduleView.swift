//
//  CCMScheduleView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
//

import UIKit

final class CCMScheduleView: UIView {
    lazy var label = makeLabel()
    lazy var switchView = makeSwitchView()
    
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
private extension CCMScheduleView {
    func initialize() {
        backgroundColor = Appearance.main200
        layer.cornerRadius = 24.scale
    }
}

// MARK: Make constraints
private extension CCMScheduleView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            switchView.widthAnchor.constraint(equalToConstant: 51.scale),
            switchView.heightAnchor.constraint(equalToConstant: 31.scale),
            switchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            switchView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension CCMScheduleView {
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.SFProRounded.regular(size: 17.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "ChooseCallMethod.Schedule".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSwitchView() -> UISwitch {
        let view = UISwitch()
        view.onTintColor = Appearance.custom52_199_89
        view.tintColor = Appearance.mono100.withAlphaComponent(0.2)
        view.thumbTintColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
