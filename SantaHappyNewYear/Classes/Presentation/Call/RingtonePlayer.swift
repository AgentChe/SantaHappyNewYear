//
//  RingtonePlayer.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 09.10.2025.
//

import AVFoundation

final class RingtonePlayer: NSObject {
    enum CallDirection {
        case incoming
        case outgoing
    }
    
    public static let shared = RingtonePlayer()
    
    private var player: AVAudioPlayer?
    
    private override init() {}
}

extension RingtonePlayer {
    func play(_ callDirection: CallDirection, loop: Bool = true, volume: Float = 1.0) {
        stop()

        let session = AVAudioSession.sharedInstance()
        
        try? session.setCategory(.playback, mode: .default, options: [.duckOthers])
        try? session.setActive(true)

        let resourceName: String = {
            switch callDirection {
            case .incoming:
                return "CallIncoming"
            case .outgoing:
                return "CallOutgoing"
            }
        }()
        
        guard
            let url = Bundle.main.url(forResource: resourceName, withExtension: "caf"),
            let player = try? AVAudioPlayer(contentsOf: url)
        else { return }

        player.numberOfLoops = loop ? -1 : 0
        player.volume = volume
        player.prepareToPlay()
        player.play()
        
        self.player = player
    }

    func stop() {
        player?.stop()
        player = nil
        
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }
}
