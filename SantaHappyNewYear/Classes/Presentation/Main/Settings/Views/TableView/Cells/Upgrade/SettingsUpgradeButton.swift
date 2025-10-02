//
//  SettingsUpgradeButton.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import UIKit

final class SettingsUpgradeButton: UIButton {
    private lazy var shadowBig = CALayer()
    private lazy var shadowNear = CALayer()
    private lazy var contentLayer = CALayer()
    private lazy var fillGradient = CAGradientLayer()
    private lazy var glossGradient = CAGradientLayer()
    private lazy var innerStroke = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let r = bounds.height / 2
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: r).cgPath

        let shadowColor = UIColor(red: 0.02, green: 0.25, blue: 0.23, alpha: 1).cgColor
        shadowNear.frame = bounds
        shadowNear.shadowPath = path
        shadowNear.shadowColor = shadowColor
        shadowNear.shadowOpacity = 0.36
        shadowNear.shadowRadius = 28.scale
        shadowNear.shadowOffset = .zero
        shadowNear.backgroundColor = UIColor.clear.cgColor

        shadowBig.frame = bounds
        shadowBig.shadowPath = path
        shadowBig.shadowColor = shadowColor
        shadowBig.shadowOpacity = 0.20
        shadowBig.shadowRadius = 36.scale
        shadowBig.shadowOffset = .zero
        shadowBig.backgroundColor = UIColor.clear.cgColor

        contentLayer.frame = bounds
        contentLayer.cornerRadius = r

        fillGradient.frame = contentLayer.bounds
        fillGradient.cornerRadius = r

        glossGradient.frame = contentLayer.bounds
        glossGradient.cornerRadius = r

        let inset: CGFloat = 2.scale
        let innerRect = contentLayer.bounds.insetBy(dx: inset, dy: inset)
        innerStroke.path = UIBezierPath(roundedRect: innerRect, cornerRadius: innerRect.height/2).cgPath
    }
}

// MARK: Private
private extension SettingsUpgradeButton {
    func initialize() {
        backgroundColor = .clear
        layer.masksToBounds = false
        
        [shadowBig, shadowNear].forEach { sl in
            sl.masksToBounds = false
            layer.addSublayer(sl)
        }

        contentLayer.masksToBounds = true
        layer.addSublayer(contentLayer)

        fillGradient.colors = [
            UIColor(red: 0.63, green: 0.75, blue: 0.72, alpha: 1).cgColor,
            UIColor(red: 0.50, green: 0.64, blue: 0.61, alpha: 1).cgColor
        ]
        fillGradient.startPoint = CGPoint(x: 0.25, y: 0.10)
        fillGradient.endPoint = CGPoint(x: 0.75, y: 0.90)
        contentLayer.addSublayer(fillGradient)

        glossGradient.colors = [
            UIColor(white: 1, alpha: 0.20).cgColor,
            UIColor(white: 1, alpha: 0.06).cgColor,
            UIColor(white: 0, alpha: 0.12).cgColor
        ]
        glossGradient.locations = [0.0, 0.45, 1.0]
        glossGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        glossGradient.endPoint   = CGPoint(x: 1.0, y: 1.0)
        contentLayer.addSublayer(glossGradient)

        innerStroke.fillColor = UIColor.clear.cgColor
        innerStroke.strokeColor = UIColor.white.withAlphaComponent(0.55).cgColor
        innerStroke.lineWidth = 1.scale
        contentLayer.addSublayer(innerStroke)
        
        let attrs = TextAttributes()
            .textColor(Appearance.custom12_57_50)
            .font(Fonts.SFProRounded.medium(size: 17.scale))
        setAttributedTitle("Settings.Upgrade.Button".localized.attributed(with: attrs), for: .normal)
    }
}
