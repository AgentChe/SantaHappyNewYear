//
//  StreamingAudioPlayer.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 10.10.2025.
//

import AVFoundation
import Accelerate

final class StreamingAudioPlayer {
    struct Config {
        var sampleRate: Double
        var channels: Int
        var bigEndian: Bool
        init(sampleRate: Double = 24_000, channels: Int = 1, bigEndian: Bool = false) {
            self.sampleRate = sampleRate
            self.channels = channels
            self.bigEndian = bigEndian
        }
    }

    private var cfg: Config
    private let engine = AVAudioEngine()
    private let node = AVAudioPlayerNode()
    private var nodeFormat: AVAudioFormat
    private var isStarted = false

    init(cfg: Config = .init()) {
        self.cfg = cfg
        self.nodeFormat = AVAudioFormat(
            standardFormatWithSampleRate: cfg.sampleRate,
            channels: AVAudioChannelCount(cfg.channels)
        )! // Float32, non-interleaved
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: nodeFormat)
    }

    /// Можно вызвать на лету, если сервер внезапно сменил SR/каналы/эндианность
    func reconfigure(sampleRate: Double? = nil, channels: Int? = nil, bigEndian: Bool? = nil) {
        let newSR = sampleRate ?? cfg.sampleRate
        let newCh = channels ?? cfg.channels
        let newBE = bigEndian ?? cfg.bigEndian
        if newSR != cfg.sampleRate || newCh != cfg.channels {
            let fmt = AVAudioFormat(standardFormatWithSampleRate: newSR,
                                    channels: AVAudioChannelCount(newCh))!
            node.stop()
            engine.pause()
            engine.disconnectNodeOutput(node)
            engine.connect(node, to: engine.mainMixerNode, format: fmt)
            try? engine.start()
            node.play()
            nodeFormat = fmt
        }
        cfg = Config(sampleRate: newSR, channels: newCh, bigEndian: newBE)
    }

    func start() {
        guard !isStarted else { return }
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .voiceChat,
                                 options: [.defaultToSpeaker, .allowBluetooth])
        try? session.setActive(true, options: [])
        try? engine.start()
        node.play()
        isStarted = true
    }

    func stop() {
        guard isStarted else { return }
        node.stop()
        engine.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        isStarted = false
    }

    /// Вход: raw PCM16 (audio/L16; rate=24000). Укажи правильные `channels` и `bigEndian` в Config.
    func enqueue(_ data: Data) {
        guard isStarted, !data.isEmpty else { return }
        let bytesPerFrame = 2 * cfg.channels
        let frames = data.count / bytesPerFrame
        guard frames > 0,
              let buf = AVAudioPCMBuffer(pcmFormat: nodeFormat,
                                         frameCapacity: AVAudioFrameCount(frames)) else { return }
        buf.frameLength = AVAudioFrameCount(frames)

        let scale: Float = 1.0 / 32768.0

        data.withUnsafeBytes { raw in
            if cfg.channels == 1 {
                if cfg.bigEndian {
                    guard let srcU16 = raw.bindMemory(to: UInt16.self).baseAddress,
                          let dst = buf.floatChannelData?[0] else { return }
                    for i in 0..<frames {
                        let s = CFSwapInt16BigToHost(srcU16[i])
                        dst[i] = Float(Int16(bitPattern: s)) * scale
                    }
                } else {
                    guard let srcI16 = raw.bindMemory(to: Int16.self).baseAddress,
                          let dst = buf.floatChannelData?[0] else { return }
                    var k = scale
                    vDSP_vflt16(srcI16, 1, dst, 1, vDSP_Length(frames))
                    vDSP_vsmul(dst, 1, &k, dst, 1, vDSP_Length(frames))
                }
            } else if cfg.channels == 2 {
                guard let l = buf.floatChannelData?[0],
                      let r = buf.floatChannelData?[1] else { return }
                if cfg.bigEndian {
                    guard let srcU16 = raw.bindMemory(to: UInt16.self).baseAddress else { return }
                    var j = 0
                    for i in 0..<frames {
                        let ls = Int16(bitPattern: CFSwapInt16BigToHost(srcU16[j])); j += 1
                        let rs = Int16(bitPattern: CFSwapInt16BigToHost(srcU16[j])); j += 1
                        l[i] = Float(ls) * scale
                        r[i] = Float(rs) * scale
                    }
                } else {
                    guard let srcI16 = raw.bindMemory(to: Int16.self).baseAddress else { return }
                    var j = 0
                    for i in 0..<frames {
                        let ls = srcI16[j]; j += 1
                        let rs = srcI16[j]; j += 1
                        l[i] = Float(ls) * scale
                        r[i] = Float(rs) * scale
                    }
                }
            }
        }

        node.scheduleBuffer(buf, completionHandler: nil)
    }
}
