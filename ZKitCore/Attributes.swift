//
//  ZKit.swift
//  ZKit
//
//  Created by zjj on 2021/9/29.
//

import UIKit

internal typealias EdgeValuePair = [Edge: CGFloat]

internal class Attribute {
    enum _Attribute {
        case width(SizeFill)
        case height(SizeFill)
        
        case alignment(EdgeValuePair)
        case padding(EdgeValuePair)
        case offset(CGPoint)
        
        case onAppear(OnAppearBlock?)
    }
    var attrs: [_Attribute] = []
    
//    var padding: [Edge: CGFloat]?
//    var offset: CGPoint = .zero
//
//    var alignment: [Edge: CGFloat]?
//    var width: SizeFill = .unknown
//    var height: SizeFill = .unknown
//
//    var onAppear: OnAppearBlock?
}

public enum SizeFill {
    case unknown
    case fillParent(multipy: CGFloat = 1, constant: CGFloat = 0)
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

internal enum Edge {
    case top, leading, bottom, trailing, centerX, centerY
}

internal enum AssociatedKey {
    static var attributeKey: Int = 0
}

public extension UIView {

    func onAppear(_ action: @escaping OnAppearBlock) -> Self {
        zk_attribute.attrs.append(.onAppear(action))
        return self
    }
    
    internal var zk_attribute: Attribute {
        get {
            if let obj = objc_getAssociatedObject(self, &AssociatedKey.attributeKey) as? Attribute {
                return obj
            }
            let newone = Attribute()
            objc_setAssociatedObject(self, &AssociatedKey.attributeKey, newone, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newone
        }
    }
    
    func frame(filledWidth: Bool? = false, filledHeight: Bool? = false) -> Self {
        let att = self.zk_attribute
        if filledWidth == true {
            att.attrs.append(.width(.fillParent()))
        }
        if filledHeight == true {
            att.attrs.append(.height(.fillParent()))
        }
        return self
    }
    
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        let att = zk_attribute
        if let w = width {
            att.attrs.append(.width(.equalTo(w)))
        }
        if let h = height {
            att.attrs.append(.height(.equalTo(h)))
        }
        return self
    }
    
    func frame(width: SizeFill = .unknown, height: SizeFill = .unknown) -> Self {
        let att = zk_attribute
        att.attrs.append(.width(width))
        att.attrs.append(.height(height))
        return self
    }
    
    func alignment(_ edges: Alignment, value: CGFloat? = 0) -> Self {
        var align = EdgeValuePair()
        if edges.contains(.centerY) {
            align[.centerY] = value
        }
        if edges.contains(.centerX) {
            align[.centerX] = value
        }
        if edges.contains(.leading) {
            align[.leading] = value
        }
        if edges.contains(.trailing) {
            align[.trailing] = value
        }
        if edges.contains(.top) {
            align[.top] = value
        }
        if edges.contains(.bottom) {
            align[.bottom] = value
        }
        if edges.isEmpty {
            return self
        }
        zk_attribute.attrs.append(.alignment(align))
        return self
    }
    
    // 未完善
    func offset(x: CGFloat, y: CGFloat) -> Self {
        let p = CGPoint(x: x, y: y)
        if p == .zero {
            return self
        }
        zk_attribute.attrs.append(.offset(p))
        return self
    }
    
    // padding将封装一个containerview
    func padding(top: CGFloat? = nil, leading: CGFloat? = nil, bottom: CGFloat? = nil, trailing: CGFloat? = nil) -> Self {
        var mar = EdgeValuePair()
        mar[.top] = top
        mar[.leading] = leading
        mar[.bottom] = bottom
        mar[.trailing] = trailing
        if mar.isEmpty {
            return self
        }
        zk_attribute.attrs.append(.padding(mar))
        return self
    }
    
    func padding(_ pad: CGFloat) -> Self {
        return padding(top: pad, leading: pad, bottom: pad, trailing: pad)
    }
}
