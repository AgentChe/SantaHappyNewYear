//
//  ChooseCallMethodViewController.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 03.10.2025.
//

import UIKit
import RxSwift

final class ChooseCallMethodViewController: UIViewController {
    enum Result {
        case nowAudio
        case nowVideo
        case scheduleAudio
        case scheduleVideo
    }
    
    private lazy var mainView = ChooseCallMethodView()
    
    private lazy var disposeBag = DisposeBag()
    
    private let didResult: (Result) -> Void
    
    private init(didResult: @escaping (Result) -> Void) {
        self.didResult = didResult
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = true
        mainView.dimmedView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind(to: Binder(self) { base, _ in
                base.dismiss()
            })
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                mainView.audioButton.rx.tap.map { CCMMethodButton.Method.audio },
                mainView.videoButton.rx.tap.map { CCMMethodButton.Method.video },
            )
            .startWith(.audio)
            .bind(to: Binder(mainView) { base, method in
                base.audioButton.marked = method == .audio
                base.videoButton.marked = method == .video
            })
            .disposed(by: disposeBag)
        
        mainView.continueButton.rx.tap
            .bind(to: Binder(self) { base, void in
                guard let result = base.makeResult() else { return }
                
                base.dismiss {
                    base.didResult(result)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainView.animateShow()
    }
}

// MARK: Public
extension ChooseCallMethodViewController {
    static func make(didResult: @escaping (Result) -> Void) -> ChooseCallMethodViewController {
        let vc = ChooseCallMethodViewController(didResult: didResult)
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

// MARK: Private
private extension ChooseCallMethodViewController {
    func dismiss(completion: (() -> Void)? = nil) {
        mainView.animateDismiss { [weak self] in
            self?.dismiss(animated: false) {
                completion?()
            }
        }
    }
    
    func makeResult() -> Result? {
        guard let method = [mainView.audioButton, mainView.videoButton].first(where: { $0.marked })?.method else { return nil }
        
        if mainView.scheduleView.switchView.isOn {
            switch method {
            case .audio:
                return .scheduleAudio
            case .video:
                return .scheduleVideo
            }
        } else {
            switch method {
            case .audio:
                return .nowAudio
            case .video:
                return .nowVideo
            }
        }
    }
}
