//
//  CCMMethodButton.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
//

import UIKit

final class CCMMethodButton: UIButton {
    enum Method {
        case audio, video
    }
    
    lazy var marked = false {
        didSet {
            update()
        }
    }
    
    lazy var pictureView = makeImageView()
    lazy var label = makeLabel()
    
    let method: Method
    
    init(method: Method) {
        self.method = method
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension CCMMethodButton {
    func initialize() {
        backgroundColor = Appearance.main200
        layer.cornerRadius = 24.scale
    }
    
    func update() {
        layer.borderWidth = marked ? 3.scale : 0
        layer.borderColor = marked ? Appearance.main100.cgColor : UIColor.clear.cgColor
    }
}

// MARK: Make constraints
private extension CCMMethodButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            pictureView.widthAnchor.constraint(equalToConstant: 100.scale),
            pictureView.heightAnchor.constraint(equalToConstant: 100.scale),
            pictureView.centerXAnchor.constraint(equalTo: centerXAnchor),
            pictureView.topAnchor.constraint(equalTo: topAnchor, constant: 20.scale)
        ])
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension CCMMethodButton {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: {
            switch method {
            case .audio:
                return "ChooseCallMethod.Audio"
            case .video:
                return "ChooseCallMethod.Video"
            }
        }())
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.main100)
            .font(Fonts.SFProRounded.semiBold(size: 21.scale))
            .lineHeight(25.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = {
            switch method {
            case .audio:
                return "ChooseCallMethod.Audio".localized.attributed(with: attrs)
            case .video:
                return "ChooseCallMethod.Video".localized.attributed(with: attrs)
            }
        }()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
