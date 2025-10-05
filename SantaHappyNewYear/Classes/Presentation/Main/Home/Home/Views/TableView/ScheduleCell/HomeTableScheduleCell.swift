//
//  HomeTableScheduleCell.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 05.10.2025.
//

import UIKit

final class HomeTableScheduleCell: UITableViewCell {
    var didTapEdit: (() -> Void)?
    var didTapCall: (() -> Void)?
    
    lazy var container = makeContainer()
    lazy var contentContainer = makeContentContainer()
    lazy var titleLabel = makeTitleLabel()
    lazy var dateTimeLabel = makeLabel()
    lazy var editButton = makeEditButton()
    lazy var callButton = makeCallButton()
    
    private lazy var dateTimeAttrs = TextAttributes()
        .textColor(Appearance.main100)
        .font(Fonts.PlayfairDisplay.bold(size: 17.scale))
        .lineHeight(28.scale)
        .textAlignment(.left)
    
    private lazy var dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM 'at' HH:mm"
        return formatter
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeTableScheduleCell {
    func setup(scheduleCall: ScheduleCall) {
        dateTimeLabel.attributedText = dateTimeFormatter.string(from: scheduleCall.dateTime).attributed(with: dateTimeAttrs)
        
        callButton.setup(iconName: {
            switch scheduleCall.method {
            case .audio:
                return "Home.ScheduleCall.Audio"
            case .video:
                return "Home.ScheduleCall.Video"
            }
        }())
    }
}

// MARK: Private
private extension HomeTableScheduleCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func editTapped() {
        didTapEdit?()
    }
    
    @objc
    func callTapped() {
        didTapCall?()
    }
}

// MARK: Make constraints
private extension HomeTableScheduleCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 80.scale),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            contentContainer.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -128.scale),
            contentContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            dateTimeLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            dateTimeLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            dateTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.scale),
            dateTimeLabel.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            editButton.widthAnchor.constraint(equalToConstant: 44.scale),
            editButton.heightAnchor.constraint(equalToConstant: 44.scale),
            editButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: callButton.leadingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            callButton.widthAnchor.constraint(equalToConstant: 44.scale),
            callButton.heightAnchor.constraint(equalToConstant: 44.scale),
            callButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            callButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HomeTableScheduleCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 20.scale
        view.layer.borderWidth = 2.scale
        view.layer.borderColor = UIColor(integralRed: 247, green: 247, blue: 247).cgColor
        view.backgroundColor = UIColor(integralRed: 245, green: 236, blue: 229, alpha: 0.9)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeContentContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.PlayfairDisplay.bold(size: 17.scale))
            .lineHeight(28.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Home.ScheduleCall.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(view)
        return view
    }
    
    func makeEditButton() -> HomeTableScheduleActionButton {
        let view = HomeTableScheduleActionButton()
        view.setup(iconName: "Home.ScheduleCall.Edit")
        view.backgroundColor = Appearance.mono100
        view.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeCallButton() -> HomeTableScheduleActionButton {
        let view = HomeTableScheduleActionButton()
        view.backgroundColor = Appearance.main100
        view.addTarget(self, action: #selector(callTapped), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
