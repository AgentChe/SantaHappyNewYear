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
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension TabView {
    func initialize() {
        backgroundColor = Appearance.main200
        layer.cornerRadius = 24.scale
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
            homeButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            homeButton.trailingAnchor.constraint(equalTo: messagesButton.leadingAnchor),
            homeButton.heightAnchor.constraint(equalToConstant: 54.scale),
            homeButton.widthAnchor.constraint(equalTo: messagesButton.widthAnchor),
            homeButton.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            messagesButton.leadingAnchor.constraint(equalTo: homeButton.trailingAnchor),
            messagesButton.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor),
            messagesButton.heightAnchor.constraint(equalToConstant: 54.scale),
            messagesButton.widthAnchor.constraint(equalTo: settingsButton.widthAnchor),
            messagesButton.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale)
        ])
        
        NSLayoutConstraint.activate([
            settingsButton.leadingAnchor.constraint(equalTo: messagesButton.trailingAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            settingsButton.heightAnchor.constraint(equalToConstant: 54.scale),
            settingsButton.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale)
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
