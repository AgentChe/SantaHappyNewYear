//
//  ProfileSetRequest.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 09.10.2025.
//

import Alamofire

struct ProfileSetRequest: APIRequestBody {
    let anonymousId: String
    let internalId: String
    let locale: String?
    
    var url: String {
        GlobalDefinitions.domain + "/api/v1/profile/attributes"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var headers: HTTPHeaders? {
        [
            "Access-Token": GlobalDefinitions.apiKey
        ]
    }
    
    var parameters: Parameters? {
        var params = [
            "anonymous_id": anonymousId,
            "internal_id": internalId
        ]
        
        if let locale {
            params["locale"] = locale
        }
        
        return params
    }
}
