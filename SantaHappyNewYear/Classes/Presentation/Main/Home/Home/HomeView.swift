//
//  HomeView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import UIKit

final class HomeView: UIView {
    lazy var imageView = makeImageView()
    lazy var actionsView = makeActionsView()
    lazy var tableContainer = makeTableContainer()
    
    private lazy var actionsViewBottomConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeView {
    func setup(elements: [ScheduleCall]) {
        let isEmpty = elements.isEmpty
        
        tableContainer.isHidden = isEmpty
        
        actionsViewBottomConstraint.isActive = false
        actionsViewBottomConstraint.constant = isEmpty ? 0 : -80.scale
        actionsViewBottomConstraint.isActive = true
        
        tableContainer.tableView.setup(elements: elements)
        
        layoutIfNeeded()
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
        
        actionsViewBottomConstraint = actionsView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        NSLayoutConstraint.activate([
            actionsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionsViewBottomConstraint
        ])
        
        NSLayoutConstraint.activate([
            tableContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableContainer.topAnchor.constraint(equalTo: actionsView.bottomAnchor, constant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeView {
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.image = UIImage(named: "Home.Image")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeActionsView() -> HomeActionsView {
        let view = HomeActionsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableContainer() -> HomeTableContainer {
        let view = HomeTableContainer()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
