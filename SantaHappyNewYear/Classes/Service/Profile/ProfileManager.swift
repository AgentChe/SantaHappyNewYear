//
//  ProfileManager.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 06.09.2024.
//

import RxSwift
import RxCocoa

protocol ProfileManagerProtocol: AnyObject {
    func create() -> Single<RequestResult>
    func binding() -> Single<RequestResult>
    func set(locale: String) -> Single<RequestResult>
}

final class ProfileManager {
    private lazy var restApiTransport = RestAPITransport()
    
    private lazy var sessionManager = SessionManager()
}

// MARK: ProfileManagerProtocol
extension ProfileManager: ProfileManagerProtocol {
    func create() -> Single<RequestResult> {
        let request = ProfileCreateRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .map { RequestResult.map(response: $0) }
    }
    
    func binding() -> Single<RequestResult> {
        let request = ProfileBindingRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .map { RequestResult.map(response: $0) }
    }
    
    func set(locale: String) -> Single<RequestResult> {
        let request = ProfileSetRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            locale: locale
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .map { RequestResult.map(response: $0) }
    }
}
