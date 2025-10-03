//
//  ChatLoadingCell.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 29.10.2024.
//

import UIKit

final class ChatLoadingCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var bottomCircleView = makeCircleView(cornerRadius: 4.scale)
    lazy var middleCircleView = makeCircleView(cornerRadius: 6.scale)
    lazy var topCircleView = makeCircleView(cornerRadius: 8.scale)

    private var timer: Timer?
    private var step = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
        applyState(animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        stopAnimating()
        step = 0
        applyState(animated: false)
    }
}

// MARK: Public
extension ChatLoadingCell {
    func startAnimating() {
        stopAnimating()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            step = (step + 1) % 3
            applyState(animated: true)
        }
    }

    func stopAnimating() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: Private
private extension ChatLoadingCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    func applyState(animated: Bool) {
        let alphas: (CGFloat, CGFloat, CGFloat) = {
            switch step {
            case 0:
                return (1, 0, 0)
            case 1:
                return (1, 1, 0)
            default:
                return (1, 1, 1)
            }
        }()

        let block = { [weak self] in
            self?.bottomCircleView.alpha = alphas.0
            self?.middleCircleView.alpha = alphas.1
            self?.topCircleView.alpha = alphas.2
        }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: block)
        } else {
            block()
        }
    }
}

// MARK: Make constraints
private extension ChatLoadingCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 37.scale)
        ])
        
        NSLayoutConstraint.activate([
            bottomCircleView.widthAnchor.constraint(equalToConstant: 8.scale),
            bottomCircleView.heightAnchor.constraint(equalToConstant: 8.scale),
            bottomCircleView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            bottomCircleView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            middleCircleView.widthAnchor.constraint(equalToConstant: 12.scale),
            middleCircleView.heightAnchor.constraint(equalToConstant: 12.scale),
            middleCircleView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 22.scale),
            middleCircleView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -9.scale)
        ])
        
        NSLayoutConstraint.activate([
            topCircleView.widthAnchor.constraint(equalToConstant: 16.scale),
            topCircleView.heightAnchor.constraint(equalToConstant: 16.scale),
            topCircleView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30.scale),
            topCircleView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -21.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatLoadingCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeCircleView(cornerRadius: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main100
        view.layer.cornerRadius = cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
