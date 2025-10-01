//
//  UIApplication+Extension.swift
//  SantaHappyNewYear
//
//  Created by Андрей Чернышев on 01.10.2025.
//

import UIKit

extension UIApplication {
    var window: UIWindow? {
        let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        return windowScene?.windows.first
    }
}
