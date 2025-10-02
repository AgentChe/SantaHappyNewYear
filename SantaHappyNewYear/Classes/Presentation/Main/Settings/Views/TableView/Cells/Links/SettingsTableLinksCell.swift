//
//  SettingsTableLinksCell.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import UIKit

final class SettingsTableLinksCell: UITableViewCell {
    var didTapURL: ((URL) -> Void)?
    
    lazy var container = makeContainer()
    lazy var termsOfUseButton = makeTermsOfUseButton()
    lazy var contactUsButton = makeContactUsButton()
    lazy var privacyPolicyButton = makePrivacyPolicyButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension SettingsTableLinksCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension SettingsTableLinksCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            termsOfUseButton.heightAnchor.constraint(equalToConstant: 68.scale),
            termsOfUseButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            termsOfUseButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            termsOfUseButton.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contactUsButton.heightAnchor.constraint(equalToConstant: 68.scale),
            contactUsButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            contactUsButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contactUsButton.topAnchor.constraint(equalTo: termsOfUseButton.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            privacyPolicyButton.heightAnchor.constraint(equalToConstant: 68.scale),
            privacyPolicyButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            privacyPolicyButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            privacyPolicyButton.topAnchor.constraint(equalTo: contactUsButton.bottomAnchor),
            privacyPolicyButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension SettingsTableLinksCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono100
        view.layer.cornerRadius = 24.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeTermsOfUseButton() -> SettingsLinkButton {
        let view = SettingsLinkButton(
            title: "Settings.Links.TermsOfUse".localized,
            withSeparator: true,
            didTap: { [weak self] in
                self?.didTapURL?(GlobalDefinitions.termsOfServiceUrl)
            }
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeContactUsButton() -> SettingsLinkButton {
        let view = SettingsLinkButton(
            title: "Settings.Links.ContactUs".localized,
            withSeparator: true,
            didTap: { [weak self] in
                self?.didTapURL?(GlobalDefinitions.contactUsUrl)
            }
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makePrivacyPolicyButton() -> SettingsLinkButton {
        let view = SettingsLinkButton(
            title: "Settings.Links.PrivacyPolicy".localized,
            withSeparator: false,
            didTap: { [weak self] in
                self?.didTapURL?(GlobalDefinitions.privacyPolicyUrl)
            }
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
