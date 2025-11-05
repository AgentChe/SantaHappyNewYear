//
//  FrontCameraView.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 08.10.2025.
//

import UIKit
import AVFoundation

final class FrontCameraView: UIView {
    private lazy var overlayLabel = makeOverlayLabel()
    
    private lazy var overlayAttrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.SFProRounded.regular(size: 16.scale))
        .textAlignment(.center)
    
    private lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.automaticallyConfiguresApplicationAudioSession = false
        return session
    }()
    private lazy var sessionQueue = DispatchQueue(label: "frontcamera.session.queue")
    private var isConfigured = false

    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    private var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewLayer.frame = bounds
    }
}

// MARK: Public
extension FrontCameraView {
    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupIfNeededAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { [weak self] in
                    granted ? self?.setupIfNeededAndStart() : self?.showDeniedUI()
                }
            }
        case .denied, .restricted:
            showDeniedUI()
        @unknown default:
            showDeniedUI()
        }
    }
    
    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, session.isRunning else { return }
            
            session.stopRunning()
        }
    }
}

// MARK: Private
private extension FrontCameraView {
    func initialize() {
        backgroundColor = Appearance.mono200
        layer.cornerRadius = 20.scale
        clipsToBounds = true
        
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    func setupIfNeededAndStart() {
        overlayLabel.isHidden = true
        sessionQueue.async { [weak self] in
            guard let self else { return }

            if !isConfigured {
                session.beginConfiguration()
                session.sessionPreset = .high

                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                    session.commitConfiguration()
                    DispatchQueue.main.async { self.showDeniedUI("VideoCall.Camera.NotAvailable".localized) }
                    return
                }

                guard let input = try? AVCaptureDeviceInput(device: device),
                      session.canAddInput(input) else {
                    session.commitConfiguration()
                    DispatchQueue.main.async {
                        self.showDeniedUI("VideoCall.Camera.Error".localized)
                    }
                    return
                }
                session.addInput(input)
                session.commitConfiguration()
                isConfigured = true

                DispatchQueue.main.async {
                    self.previewLayer.session = self.session
                }
            } else {
                DispatchQueue.main.async {
                    if self.previewLayer.session == nil { self.previewLayer.session = self.session }
                }
            }
            
            guard !session.inputs.isEmpty, !session.isRunning else { return }
            session.startRunning()
        }
    }
    
    func showDeniedUI(_ message: String? = nil) {
        overlayLabel.attributedText = (message ?? "VideoCall.Camera.NotPermissions".localized).attributed(with: overlayAttrs)
        overlayLabel.isHidden = false
        previewLayer.session = nil
    }
}

// MARK: Make constraints
extension FrontCameraView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            overlayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            overlayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            overlayLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension FrontCameraView {
    func makeOverlayLabel() -> UILabel {
        let view = UILabel()
        view.isHidden = true
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
