//
//  HomeView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import UIKit

final class HomeView: UIView {
    lazy var imageView = makeImageView()
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
private extension HomeView {
    func initialize() {
        backgroundColor = Appearance.custom227_188_136
    }
}

// MARK: Make constraints
private extension HomeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 730 / 874)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -80.scale)
        ])
        
        NSLayoutConstraint.activate([
            callSantaButton.widthAnchor.constraint(equalToConstant: 175.scale),
            callSantaButton.heightAnchor.constraint(equalToConstant: 60.scale),
            callSantaButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -6.scale),
            callSantaButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            writeMessageButton.widthAnchor.constraint(equalToConstant: 175.scale),
            writeMessageButton.heightAnchor.constraint(equalToConstant: 60.scale),
            writeMessageButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 6.scale),
            writeMessageButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 20.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.clipsToBounds = true
        view.image = UIImage(named: "Home.Image")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
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
