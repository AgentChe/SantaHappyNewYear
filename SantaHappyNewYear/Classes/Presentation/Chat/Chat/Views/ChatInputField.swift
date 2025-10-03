//
//  ChatInputField.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 26.10.2024.
//

import UIKit

final class ChatInputField: UIView {
    lazy var inputContainer = makeInputContainer()
    lazy var textField = makeTextField()
    lazy var audioButton = makeAudioButton()
    lazy var sendButton = makeSendButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UITextFieldDelegate
extension ChatInputField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Private
private extension ChatInputField {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension ChatInputField {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60.scale),
            inputContainer.topAnchor.constraint(equalTo: topAnchor),
            inputContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -46.scale),
            textField.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            textField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            audioButton.widthAnchor.constraint(equalToConstant: 18.scale),
            audioButton.heightAnchor.constraint(equalToConstant: 20.scale),
            audioButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -28.scale),
            audioButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            sendButton.widthAnchor.constraint(equalToConstant: 48.scale),
            sendButton.heightAnchor.constraint(equalToConstant: 48.scale),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatInputField {
    func makeInputContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono100
        view.layer.cornerRadius = 24.scale
        view.layer.shadowColor = Appearance.mono200.withAlphaComponent(0.6).cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTextField() -> PaddingTextField {
        let placeholderAttrs = TextAttributes()
            .textColor(Appearance.custom217)
            .font(Fonts.SFProRounded.medium(size: 17.scale))
            .lineHeight(20.scale)
            .textAlignment(.left)
        let textAttrs = TextAttributes()
            .textColor(Appearance.custom64)
            .font(Fonts.SFProRounded.medium(size: 17.scale))
            .lineHeight(20.scale)
            .textAlignment(.left)
        
        let view = PaddingTextField()
        view.textPadding = UIEdgeInsets(t: 14.scale, l: 16.scale, b: 14.scale, r: 50.scale)
        view.defaultTextAttributes = textAttrs.dictionary
        view.attributedPlaceholder = "Chat.Input.Placeholder".localized.attributed(with: placeholderAttrs)
        view.delegate = self
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(view)
        return view
    }
    
    func makeAudioButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Chat.Audio"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(view)
        return view
    }
    
    func makeSendButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.layer.cornerRadius = 24.scale
        view.backgroundColor = Appearance.mono100
        view.layer.shadowColor = Appearance.mono200.withAlphaComponent(0.6).cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4.scale
        view.setImage(UIImage(named: "Chat.SendMessage"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
