//
//  ZKit.swift
//  ZKit
//
//  Created by zjj on 2021/9/29.
//

import UIKit

public class Attribute {
    var padding: [Edge: CGFloat]?
    var offset: CGPoint = .zero
    
    var alignment: [Edge: CGFloat]?
    var width: SizeFill?
    var height: SizeFill?
    
    var onAppear: OnAppearBlock?
}

public enum SizeFill {
    case fillParent
    case equalTo(_ size: CGFloat)
    // 更多规则未完待续
}

public typealias OnAppearBlock = (UIView) -> Void

public struct Alignment: OptionSet {
    public typealias RawValue = Int
    public let rawValue: RawValue
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public static let leading = Alignment(rawValue: 1 << 0)
    public static let trailing = Alignment(rawValue: 1 << 1)
    public static let top = Alignment(rawValue: 1 << 2)
    public static let bottom = Alignment(rawValue: 1 << 3)
    public static let allEdges: Alignment = [.leading, .trailing, .top, .bottom]
    
    public static let centerX = Alignment(rawValue: 1 << 4)
    public static let centerY = Alignment(rawValue: 1 << 5)
    public static let center: Alignment = [centerX, centerY]
}

public enum Edge {
    case top, leading, bottom, trailing, centerX, centerY
}

public enum AssociatedKey {
    static var attributeKey: Int = 0
}
