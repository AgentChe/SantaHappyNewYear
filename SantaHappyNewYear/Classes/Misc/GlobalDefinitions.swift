//
//  GlobalDefinitions.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

final class GlobalDefinitions {
    static let domain = "https://santa.korrekted.com"
    static let wssDomain = "wss://santa.korrekted.com"
    static let apiKey = "v7m5rcLUz4j6XIPGpw"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "1NcNunx2ErwH6YLc"
    
    static let termsOfServiceUrl = URL(string: "https://apps-and-taps.com/terms")!
    static let privacyPolicyUrl = URL(string: "https://apps-and-taps.com/policy")!
    static let contactUsUrl = URL(string: "https://apps-and-taps.com/#contact")!
    
    enum Paygate {
        static let yearly = "iphone.santa.chat.yearly"
        static let weekly = "iphone.santa.chat.weekly"
    }
}
