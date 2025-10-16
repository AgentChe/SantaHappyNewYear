//
//  VideoSantaAnimationView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 16.10.2025.
//

import UIKit
import AVFoundation

final class VideoSantaAnimationView: UIView {
    enum Animation {
        case listening, speaking
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var currentAnimation: Animation?

    override init(frame: CGRect) {
        super.init(frame: frame)

        playerLayer.videoGravity = .resizeAspectFill

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }
}

// MARK: Public
extension VideoSantaAnimationView {
    func setup(animation: Animation) {
        isHidden = false
        
        set(animation)
    }

    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        tearDownPlayer()
    }
}

// MARK: - Private
private extension VideoSantaAnimationView {
    func set(_ animation: Animation) {
        guard currentAnimation != animation || player == nil else { return }

        tearDownPlayer()

        guard let url = url(for: animation) else { return }

        let item = AVPlayerItem(url: url)
        item.preferredForwardBufferDuration = 0

        let queuePlayer = AVQueuePlayer()
        queuePlayer.automaticallyWaitsToMinimizeStalling = false
        queuePlayer.actionAtItemEnd = .none
        queuePlayer.allowsExternalPlayback = false

        player = queuePlayer
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        playerLayer.player = queuePlayer

        queuePlayer.play()
        currentAnimation = animation
    }

    func url(for animation: Animation) -> URL? {
        let name: String = {
            switch animation {
            case .listening:
                return "Santa.Listening"
            case .speaking:
                return "Santa.Speaking"
            }
        }()
        return Bundle.main.url(forResource: name, withExtension: "MP4")
    }

    func tearDownPlayer() {
        playerLayer.player = nil
        looper = nil
        player?.pause()
        player = nil
        currentAnimation = nil
    }

    @objc
    func appDidEnterBackground() {
        player?.pause()
    }
    
    @objc
    func appWillEnterForeground() {
        player?.play()
    }
}
