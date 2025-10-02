//
//  TabView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import UIKit

final class TabView: UIView {
    enum Tab {
        case home, messages, settings
    }
    
    lazy var homeButton = makeButton(code: "Main.Home")
    lazy var messagesButton = makeButton(code: "Main.Messages")
    lazy var settingsButton = makeButton(code: "Main.Settings")
    
    var selectedTab = Tab.home {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension TabView {
    func initialize() {
        backgroundColor = Appearance.mono100.withAlphaComponent(0.4)
        layer.borderColor = Appearance.mono100.cgColor
        layer.borderWidth = 1.scale
        layer.cornerRadius = 29.scale
        layer.masksToBounds = true
    }
    
    func update() {
        homeButton.marked = selectedTab == .home
        messagesButton.marked = selectedTab == .messages
        settingsButton.marked = selectedTab == .settings
    }
}

// MARK: Make constraints
private extension TabView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            homeButton.heightAnchor.constraint(equalToConstant: 50.scale),
            homeButton.widthAnchor.constraint(equalToConstant: 102.scale),
            homeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4.scale),
            homeButton.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale),
            homeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.scale)
        ])
        
        NSLayoutConstraint.activate([
            messagesButton.heightAnchor.constraint(equalToConstant: 50.scale),
            messagesButton.widthAnchor.constraint(equalToConstant: 102.scale),
            messagesButton.leadingAnchor.constraint(equalTo: homeButton.trailingAnchor),
            messagesButton.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale),
            messagesButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.scale)
        ])
        
        NSLayoutConstraint.activate([
            settingsButton.heightAnchor.constraint(equalToConstant: 50.scale),
            settingsButton.widthAnchor.constraint(equalToConstant: 102.scale),
            settingsButton.leadingAnchor.constraint(equalTo: messagesButton.trailingAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.scale),
            settingsButton.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale),
            settingsButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension TabView {
    func makeButton(code: String) -> TabItemButton {
        let view = TabItemButton(code: code)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
