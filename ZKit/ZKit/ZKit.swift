//
//  ZKit.swift
//  ZKit
//
//  Created by zjj on 2021/9/29.
//

import UIKit

enum ZKit {
    class PaddingContainerView: UIView {
        
    }
    
    class Attribute {
        var margin: [Edges: CGFloat]?
        
        var alignment: Alignment?
        var width: CGFloat?
        var height: CGFloat?
        
        var filledWidth: Bool = false
        var filledHeight: Bool = false
    }
    
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
    
    enum Edges {
        case top, leading, bottom, trailing
    }
    
    enum AssociatedKey {
        static var attributeKey: Int = 0
        static var onAppearKey: Int = 0
        static var onDisappearKey: Int = 0
    }
}

