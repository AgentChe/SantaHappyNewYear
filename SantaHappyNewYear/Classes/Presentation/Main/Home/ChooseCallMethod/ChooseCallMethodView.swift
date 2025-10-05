//
//  ChooseCallMethodView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
//

import UIKit

final class ChooseCallMethodView: UIView {
    lazy var dimmedView = makeDimmedView()
    lazy var container = makeContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var audioButton = makeMethodButton(method: .audio)
    lazy var videoButton = makeMethodButton(method: .video)
    lazy var scheduleView = makeScheduleView()
    lazy var continueButton = makeContinueButton()
    
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
extension ChooseCallMethodView {
    func animateShow() {
        containerYConstraint.isActive = false
        containerYConstraint = container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -27.scale)
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
private extension ChooseCallMethodView {
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
            container.heightAnchor.constraint(equalToConstant: 425.scale),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            audioButton.widthAnchor.constraint(equalToConstant: 165.scale),
            audioButton.heightAnchor.constraint(equalToConstant: 175.scale),
            audioButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 80.scale),
            audioButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            videoButton.widthAnchor.constraint(equalToConstant: 165.scale),
            videoButton.heightAnchor.constraint(equalToConstant: 175.scale),
            videoButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 80.scale),
            videoButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.scale)
        ])
        
        NSLayoutConstraint.activate([
            scheduleView.heightAnchor.constraint(equalToConstant: 60.scale),
            scheduleView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            scheduleView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            scheduleView.topAnchor.constraint(equalTo: audioButton.bottomAnchor, constant: 14.scale)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: 60.scale),
            continueButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            continueButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            continueButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChooseCallMethodView {
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
        view.backgroundColor = Appearance.mono100
        view.layer.cornerRadius = 40.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.PlayfairDisplay.bold(size: 27.scale))
            .lineHeight(36.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "ChooseCallMethod.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeMethodButton(method: CCMMethodButton.Method) -> CCMMethodButton {
        let view = CCMMethodButton(method: method)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeScheduleView() -> CCMScheduleView {
        let view = CCMScheduleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.SFProRounded.medium(size: 17.scale))
        
        let view = UIButton()
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = 30.scale
        view.setAttributedTitle("Continue".localized.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
