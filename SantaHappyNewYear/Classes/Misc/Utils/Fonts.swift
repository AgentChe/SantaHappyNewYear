//
//  Fonts.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import UIKit

struct Fonts {
    struct SFProRounded {
        static func regular(size: CGFloat) -> UIFont {
            .rounded(ofSize: size, weight: .regular)
        }
        
        static func medium(size: CGFloat) -> UIFont {
            .rounded(ofSize: size, weight: .medium)
        }
        
        static func semiBold(size: CGFloat) -> UIFont {
            .rounded(ofSize: size, weight: .semibold)
        }
        
        static func bold(size: CGFloat) -> UIFont {
            .rounded(ofSize: size, weight: .bold)
        }
    }
    
    struct PlayfairDisplay {
        static func bold(size: CGFloat) -> UIFont {
            UIFont(name: "PlayfairDisplay-Bold", size: size)!
        }
        
        static func medium(size: CGFloat) -> UIFont {
            UIFont(name: "PlayfairDisplay-Medium", size: size)!
        }
        
        static func regular(size: CGFloat) -> UIFont {
            UIFont(name: "PlayfairDisplay-Regular", size: size)!
        }
        
        static func semiBold(size: CGFloat) -> UIFont {
            UIFont(name: "PlayfairDisplay-SemiBold", size: size)!
        }
        
        static func extraBold(size: CGFloat) -> UIFont {
            UIFont(name: "PlayfairDisplay-ExtraBold", size: size)!
        }
    }
}

// MARK: Private
private extension UIFont {
    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        if let d = base.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: d, size: size)
        }
        return base
    }
}
