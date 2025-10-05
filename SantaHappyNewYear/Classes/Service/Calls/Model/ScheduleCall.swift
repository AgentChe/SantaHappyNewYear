//
//  ScheduleCall.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 05.10.2025.
//

import Foundation

struct ScheduleCall: Codable {
    enum Method: Codable {
        case audio, video
    }
    
    let id: String
    let method: Method
    let dateTime: Date
}
