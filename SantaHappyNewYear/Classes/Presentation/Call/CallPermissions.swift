//
//  CallPermissions.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 23.10.2025.
//

import AVFoundation
import Speech
import UIKit

enum CallPermissionsError: Error {
    case speechDenied
    case micDenied
    case cameraDenied
}

final class CallPermissions {
    static func requestAll(requireVideo: Bool = true,
                           completion: @escaping (Result<Void, CallPermissionsError>) -> Void) {
        DispatchQueue.main.async {
            requestSpeech { speechRes in
                switch speechRes {
                case .failure: completion(.failure(.speechDenied)); return
                case .success:
                    requestMic { micRes in
                        switch micRes {
                        case .failure: completion(.failure(.micDenied)); return
                        case .success:
                            guard requireVideo else { completion(.success(())); return }
                            requestCamera { camRes in
                                switch camRes {
                                case .failure: completion(.failure(.cameraDenied))
                                case .success: completion(.success(()))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    static func openErrorAlert(from: UIViewController, error: CallPermissionsError) {
        let alert = UIAlertController(title: "CallPermissions.Error.Title".localized, message: "CallPermissions.Error.Message".localized, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK".localized, style: .cancel)
        alert.addAction(okAction)
        
        from.present(alert, animated: true)
    }
    
    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - Private helpers
private extension CallPermissions {
    static func requestSpeech(_ completion: @escaping (Result<Void, Error>) -> Void) {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            completion(.success(()))
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    status == .authorized ? completion(.success(()))
                                          : completion(.failure(CallPermissionsError.speechDenied))
                }
            }
        default:
            completion(.failure(CallPermissionsError.speechDenied))
        }
    }

    static func requestMic(_ completion: @escaping (Result<Void, Error>) -> Void) {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            completion(.success(()))
        case .undetermined:
            session.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    granted ? completion(.success(()))
                            : completion(.failure(CallPermissionsError.micDenied))
                }
            }
        case .denied:
            completion(.failure(CallPermissionsError.micDenied))
        @unknown default:
            completion(.failure(CallPermissionsError.micDenied))
        }
    }

    static func requestCamera(_ completion: @escaping (Result<Void, Error>) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(.success(()))
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? completion(.success(()))
                            : completion(.failure(CallPermissionsError.cameraDenied))
                }
            }
        case .denied, .restricted:
            completion(.failure(CallPermissionsError.cameraDenied))
        @unknown default:
            completion(.failure(CallPermissionsError.cameraDenied))
        }
    }
}
