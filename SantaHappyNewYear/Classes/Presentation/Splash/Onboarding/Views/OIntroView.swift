//
//  OSantaCallingView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 09.10.2025.
//

import UIKit

final class OIntroView: UIView {
    enum Intro {
        case santaCalling
        case scheduleCall
        case chatWithSanta
    }
    
    lazy var imageView = makeImageView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var continueButton = makeContinueButton()
    
    private let intro: Intro
    private let didTapContinue: () -> Void
    
    init(intro: Intro, didTapContinue: @escaping () -> Void) {
        self.intro = intro
        self.didTapContinue = didTapContinue
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension OIntroView {
    func initialize() {
        backgroundColor = Appearance.main200
    }
    
    @objc
    func continueTapped() {
        didTapContinue()
    }
}

// MARK: Make constraints
private extension OIntroView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 661 / 874)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.centerYAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.scale)
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            continueButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20.scale),
            continueButton.heightAnchor.constraint(equalToConstant: 60.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension OIntroView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.image = UIImage(named: {
            switch intro {
            case .santaCalling:
                return "Onboarding.SantaCalling"
            case .scheduleCall:
                return "Onboarding.Schedule"
            case .chatWithSanta:
                return "Onboarding.ChatWithSanta"
            }
        }())
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.main100)
            .font(Fonts.PlayfairDisplay.bold(size: 31.scale))
            .lineHeight(41.scale)
            .textAlignment(.left)
        
        let title: String = {
            switch intro {
            case .santaCalling:
                return "Onboarding.SantaCalling.Title".localized
            case .scheduleCall:
                return "Onboarding.Schedule.Title".localized
            case .chatWithSanta:
                return "Onboarding.ChatWithSanta.Title".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.SFProRounded.regular(size: 17.scale))
            .lineHeight(24.scale)
            .textAlignment(.left)
        
        let subTitle: String = {
            switch intro {
            case .santaCalling:
                return "Onboarding.SantaCalling.SubTitle".localized
            case .scheduleCall:
                return "Onboarding.Schedule.SubTitle".localized
            case .chatWithSanta:
                return "Onboarding.ChatWithSanta.SubTitle".localized
            }
        }()
        
        let view = UILabel()
        view.attributedText = subTitle.attributed(with: attrs)
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeContinueButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.SFProRounded.medium(size: 17.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Continue".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = 30.scale
        view.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
