//
//  ZKit.swift
//  ZKit
//
//  Created by zjj on 2021/9/29.
//

import UIKit

enum ZKit {
    
}

extension ZKit {
    class Attribute {
        var padding: [Edge: CGFloat]?
        var offset: CGPoint = .zero
        
        var alignment: [Edge: CGFloat]?
        var width: SizeFill?
        var height: SizeFill?
        
        var onAppear: OnAppearBlock?
    }
    
    enum SizeFill {
        case fillParent
        case equalTo(_ size: CGFloat)
        // 更多规则未完待续
    }
    
    typealias OnAppearBlock = (UIView) -> Void
    
    struct Alignment: OptionSet {
        typealias RawValue = Int
        let rawValue: RawValue
        
        static let leading = Alignment(rawValue: 1 << 0)
        static let trailing = Alignment(rawValue: 1 << 1)
        static let top = Alignment(rawValue: 1 << 2)
        static let bottom = Alignment(rawValue: 1 << 3)
        static let allEdges: Alignment = [.leading, .trailing, .top, .bottom]
        
        static let centerX = Alignment(rawValue: 1 << 4)
        static let centerY = Alignment(rawValue: 1 << 5)
        static let center: Alignment = [centerX, centerY]
    }
    
    enum Edge {
        case top, leading, bottom, trailing, centerX, centerY
    }
    
    enum AssociatedKey {
        static var attributeKey: Int = 0
    }
}

