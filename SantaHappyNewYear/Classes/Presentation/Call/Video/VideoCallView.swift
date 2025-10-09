//
//  VideoCallView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 08.10.2025.
//

import UIKit

final class VideoCallView: UIView {
    enum CallPhase {
        case ringing
        case active(Int)
    }
    
    enum CallUIState {
        case awaitingPickup
        case inConversation
    }
    
    lazy var backgroundView = makeBackgroundView()
    lazy var titleLabel = makeTitleLabel()
    lazy var subTitleLabel = makeSubTitleLabel()
    lazy var rejectButton = makeRejectButton()
    lazy var acceptButton = makeAcceptButton()
    lazy var frontCameraView = makeFrontCameraView()
    
    private lazy var subTitleAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.SFProRounded.regular(size: 17.scale))
        .lineHeight(20.scale)
        .textAlignment(.center)
    
    private lazy var rejectButtonHorizontalConstraint = NSLayoutConstraint()
    
    private let callDirection: VideoCallViewController.CallDirection
    
    init(callDirection: VideoCallViewController.CallDirection) {
        self.callDirection = callDirection
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension VideoCallView {
    func setup(callPhase: CallPhase) {
        switch callPhase {
        case .ringing:
            let string: String = {
                switch callDirection {
                case .incoming:
                    return "VideoCall.Phase.Incoming".localized
                case .outgoing:
                    return "VideoCall.Phase.Outgoing" .localized
                }
            }()
            subTitleLabel.attributedText = string.attributed(with: subTitleAttrs)
        case .active(let seconds):
            let string = String(format: "%02d:%02d", seconds / 60, seconds % 60)
            subTitleLabel.attributedText = string.attributed(with: subTitleAttrs)
        }
    }
    
    func setup(callUIState: CallUIState) {
        func updateButtonsPosition() {
            guard callDirection == .incoming else { return }
            
            acceptButton?.isHidden = callUIState == .inConversation
            
            rejectButtonHorizontalConstraint.isActive = false
            
            switch callUIState {
            case .awaitingPickup:
                rejectButtonHorizontalConstraint = rejectButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 57.scale)
            case .inConversation:
                rejectButtonHorizontalConstraint = rejectButton.centerXAnchor.constraint(equalTo: centerXAnchor)
            }
            
            rejectButtonHorizontalConstraint.isActive = true
        }
        
        func updateFrontCamera() {
            frontCameraView.isHidden = callUIState == .awaitingPickup
            
            if callUIState == .inConversation {
                frontCameraView.start()
            }
        }
        
        updateButtonsPosition()
        updateFrontCamera()
        
        layoutIfNeeded()
    }
}

// MARK: Private
private extension VideoCallView {
    func initialize() {
        backgroundColor = Appearance.main200
    }
}

// MARK: Make constraints
private extension VideoCallView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale)
        ])
        
        if let acceptButton {
            rejectButtonHorizontalConstraint = rejectButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 57.scale)
            NSLayoutConstraint.activate([
                rejectButton.widthAnchor.constraint(equalToConstant: 80.scale),
                rejectButton.heightAnchor.constraint(equalToConstant: 80.scale),
                rejectButtonHorizontalConstraint,
                rejectButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -36.scale)
            ])
            
            NSLayoutConstraint.activate([
                acceptButton.widthAnchor.constraint(equalToConstant: 80.scale),
                acceptButton.heightAnchor.constraint(equalToConstant: 80.scale),
                acceptButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -57.scale),
                acceptButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -36.scale)
            ])
        } else {
            NSLayoutConstraint.activate([
                rejectButton.widthAnchor.constraint(equalToConstant: 80.scale),
                rejectButton.heightAnchor.constraint(equalToConstant: 80.scale),
                rejectButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                rejectButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -36.scale)
            ])
        }
        
        NSLayoutConstraint.activate([
            frontCameraView.widthAnchor.constraint(equalToConstant: 129.scale),
            frontCameraView.heightAnchor.constraint(equalToConstant: 189.scale),
            frontCameraView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -13.scale),
            frontCameraView.bottomAnchor.constraint(equalTo: rejectButton.centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension VideoCallView {
    func makeBackgroundView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "Video.Background")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.PlayfairDisplay.medium(size: 44.scale))
            .lineHeight(59.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "VideoCall.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSubTitleLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeAcceptButton() -> UIButton? {
        guard callDirection == .incoming else { return nil }
        
        let view = UIButton()
        view.backgroundColor = UIColor.clear
        view.setImage(UIImage(named: "Video.Accept"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeRejectButton() -> UIButton {
        let view = UIButton()
        view.backgroundColor = UIColor.clear
        view.setImage(UIImage(named: "Video.Reject"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeFrontCameraView() -> FrontCameraView {
        let view = FrontCameraView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
