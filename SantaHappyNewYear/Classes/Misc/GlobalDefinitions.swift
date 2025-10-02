//
//  GlobalDefinitions.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

// TODO
final class GlobalDefinitions {
    static let domain = "https://hair.thinkaboutapps.com"
    static let apiKey = "K9tK6iIQ4mZZNnWhs9c9y3DI"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "v6yHI2AQpAq7YNYX"
    
    static let applicationTag = "SMART_CLOSET"
    static let amplitudeApiKey = "17fa94a421fa4349d8b1db59c8e06fbe"
    
    static let termsOfServiceUrl = URL(string: "https://camplain-apps.com/terms-of-use.html")!
    static let privacyPolicyUrl = URL(string: "https://camplain-apps.com/privacy-policy.html")!
    static let contactUsUrl = URL(string: "https://camplain-apps.com/contacts.html")!
    
    enum Paygate {
        static let yearly = "santa.yearly"
        static let weekly = "santa.weekly"
    }
}
