//
//  OnboardingView.swift
//  Soccer
//
//  Created by Андрей Чернышев on 23.08.2022.
//

import UIKit

final class OnboardingView: GradientView {
    enum Slide: Hashable {
        case santaCalling
        case scheduleCall
        case chatWithSanta
    }
    
    private lazy var slidesViews: [Slide: UIView] = [
        .santaCalling: OIntroView(intro: .santaCalling) { [weak self] in
            self?.scroll(from: .santaCalling, to: .scheduleCall)
        },
        .scheduleCall: OIntroView(intro: .scheduleCall) { [weak self] in
            self?.scroll(from: .scheduleCall, to: .chatWithSanta)
        },
        .chatWithSanta: OIntroView(intro: .chatWithSanta) { [weak self] in
            self?.finish()
        }
    ]
    
    private let finish: () -> Void
    
    init(finish: @escaping () -> Void) {
        self.finish = finish
        
        super.init(frame: .zero)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        slidesViews.map { $1 }.forEach { slideView in
            slideView.frame.size = bounds.size
        }
    }
}

// MARK: Private
private extension OnboardingView {
    func initialize() {
        backgroundColor = Appearance.main200
        
        if let view = slidesViews[.santaCalling] {
            view.frame.origin = CGPoint.zero
            addSubview(view)
        }
    }
    
    func scroll(from: Slide, to: Slide) {
        guard let currentView = slidesViews[from], let scrollToView = slidesViews[to] else { return }
        
        scrollToView.frame.origin = CGPoint(x: bounds.size.width, y: 0)
        
        addSubview(scrollToView)
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            
            currentView.frame.origin = CGPoint(x: -bounds.size.width, y: 0)
            scrollToView.frame.origin = CGPoint(x: 0, y: 0)
        }, completion: { result in
            currentView.removeFromSuperview()
        })
    }
}
