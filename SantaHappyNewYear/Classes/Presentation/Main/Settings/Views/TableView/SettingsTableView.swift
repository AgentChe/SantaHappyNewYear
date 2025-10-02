//
//  SettingsTableView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingsTableView: UITableView {
    private lazy var elements = [SettingsTableElement]()
    
    private lazy var didTapUpgradeTrigger = PublishRelay<Void>()
    private lazy var didTapLinkTrigger = PublishRelay<URL>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SettingsTableView {
    func setup(elements: [SettingsTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapUpgrade: Signal<Void> {
        didTapUpgradeTrigger.asSignal()
    }
    
    var didTapLink: Signal<URL> {
        didTapLinkTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension SettingsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .upgrade:
            let cell = dequeueReusableCell(withIdentifier: String(describing: SettingsTableUpgradeCell.self), for: indexPath) as! SettingsTableUpgradeCell
            cell.didTapUpgrade = { [weak self] in
                self?.didTapUpgradeTrigger.accept(Void())
            }
            return cell
        case .links:
            let cell = dequeueReusableCell(withIdentifier: String(describing: SettingsTableLinksCell.self), for: indexPath) as! SettingsTableLinksCell
            cell.didTapURL = { [weak self] url in
                self?.didTapLinkTrigger.accept(url)
            }
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension SettingsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension SettingsTableView {
    func initialize() {
        backgroundColor = UIColor.clear
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(vertical: 16.scale)
        setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        separatorStyle = .none
        
        register(SettingsTableUpgradeCell.self, forCellReuseIdentifier: String(describing: SettingsTableUpgradeCell.self))
        register(SettingsTableLinksCell.self, forCellReuseIdentifier: String(describing: SettingsTableLinksCell.self))
        
        dataSource = self
        delegate = self
    }
}
