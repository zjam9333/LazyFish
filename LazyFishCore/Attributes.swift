//
//  LazyFish.swift
//  LazyFish
//
//  Created by zjj on 2021/9/29.
//

import UIKit

public enum ValueBinding<T> {
    case constant(T)
    case binding(Binding<T>)
}

internal typealias EdgeValuePair = [Edge: CGFloat]

internal class Attribute {
    enum _Attribute {
        case width(SizeFill)
        case height(SizeFill)
        
        case alignment(EdgeValuePair)
        
        case onAppear(OnAppearBlock?)
    }
    var attrs: [_Attribute] = []
    
    private static var attributeKey: Int = 0
    
    internal static func attribute(from view: UIView) -> Attribute {
        if let obj = objc_getAssociatedObject(view, &attributeKey) as? Attribute {
            return obj
        }
        let newone = Attribute()
        objc_setAssociatedObject(view, &attributeKey, newone, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newone
    }
}

internal enum SizeFill {
    internal enum Dimension {
        case x, y
    }
    
    case unknown
    case equal(_ size: ValueBinding<CGFloat>)
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

public extension UIView {

    func onAppear(_ action: @escaping OnAppearBlock) -> Self {
        Attribute.attribute(from: self).attrs.append(.onAppear(action))
        return self
    }
    
    func frame(width: CGFloat, height: CGFloat) -> Self {
        let att = Attribute.attribute(from: self)
        att.attrs.append(.width(.equal(.constant(width))))
        att.attrs.append(.height(.equal(.constant(height))))
        return self
    }

    
    func frame(width: CGFloat) -> Self {
        let att = Attribute.attribute(from: self)
        att.attrs.append(.width(.equal(.constant(width))))
        return self
    }
    
    func frame(height: CGFloat) -> Self {
        let att = Attribute.attribute(from: self)
        att.attrs.append(.height(.equal(.constant(height))))
        return self
    }
    
    func frame(width: Binding<CGFloat>) -> Self {
        let att = Attribute.attribute(from: self)
        att.attrs.append(.width(.equal(.binding(width))))
        return self
    }
    
    func frame(height: Binding<CGFloat>) -> Self {
        let att = Attribute.attribute(from: self)
        att.attrs.append(.height(.equal(.binding(height))))
        return self
    }
    
    func frame(width: Binding<CGFloat>, height: Binding<CGFloat>) -> Self {
        let att = Attribute.attribute(from: self)
        att.attrs.append(.width(.equal(.binding(width))))
        att.attrs.append(.height(.equal(.binding(height))))
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
        Attribute.attribute(from: self).attrs.append(.alignment(align))
        return self
    }
    
    // 未完善
//    func offset(x: CGFloat = 0, y: CGFloat = 0) -> UIView {
//        let p = CGPoint(x: x, y: y)
//        if p == .zero {
//            return self
//        }
//
//        return PaddingContainerView(self, offset: p)
//    }
    
    /// padding将封装一个containerview，返回普通UIView类型
    func padding(top: CGFloat? = nil, leading: CGFloat? = nil, bottom: CGFloat? = nil, trailing: CGFloat? = nil) -> UIView {
        var mar = EdgeValuePair()
        mar[.top] = top
        mar[.leading] = leading
        mar[.bottom] = bottom
        mar[.trailing] = trailing
        // 全空、全0
        if mar.isEmpty || mar.reduce(0, { partialResult, item in
            return partialResult + item.value
        }) == 0 {
            return self
        }
        return PaddingContainerView(self, padding: mar)
    }
    
    /// padding将封装一个containerview，返回普通UIView类型
    func padding(_ pad: CGFloat) -> UIView {
        return padding(top: pad, leading: pad, bottom: pad, trailing: pad)
    }
    
    /// padding将封装一个containerview，返回普通UIView类型
    func padding(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> UIView {
        return padding(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}
