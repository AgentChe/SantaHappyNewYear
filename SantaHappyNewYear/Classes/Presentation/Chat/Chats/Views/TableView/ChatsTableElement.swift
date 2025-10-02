//
//  ChatsTableElement.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 02.10.2025.
//

import Foundation

struct ChatsTableElement {
    let date: String
    let chat: Chat
    
    static private let ddMMFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
    static private let ddMMYYYYFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    init(chat: Chat) {
        self.date = {
            let calendar = Calendar.current
            
            let date = chat.lastMessage.created
            
            if calendar.isDateInToday(date) {
                return "Chats.Today".localized
            }
            
            if calendar.isDateInTomorrow(date) {
                return "Chats.Tomorrow".localized
            }
            
            let now = Date()
            let sameYear = calendar.component(.year, from: date) == calendar.component(.year, from: now)
            
            let formatter = sameYear ? Self.ddMMFormatter : Self.ddMMYYYYFormatter
            return formatter.string(from: date)
        }()
        self.chat = chat
    }
}
