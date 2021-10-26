//
//  ZKitLayout.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

public extension UIView {

    func onAppear(_ action: @escaping OnAppearBlock) -> Self {
        self.zk_attribute.onAppear = action
        return self
    }
    
    internal var zk_attribute: Attribute {
        set {
            let obj = newValue
            objc_setAssociatedObject(self, &AssociatedKey.attributeKey, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let obj = objc_getAssociatedObject(self, &AssociatedKey.attributeKey) as? Attribute {
                return obj
            }
            let newone = Attribute()
            self.zk_attribute = newone
            return newone
        }
    }
    
    func frame(filledWidth: Bool? = false, filledHeight: Bool? = false) -> Self {
        if let w = filledWidth, w == true {
            _ = self.frame(width: .fillParent)
        }
        if let h = filledHeight, h == true {
            _ = self.frame(height: .fillParent)
        }
        return self
    }
    
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        if let w = width {
            _ = self.frame(width: .equalTo(w))
        }
        if let h = height {
            _ = self.frame(height: .equalTo(h))
        }
        return self
    }
    
    func frame(width: SizeFill? = nil, height: SizeFill? = nil) -> Self {
        let att = self.zk_attribute
        att.width = width ?? att.width
        att.height = height ?? att.height
        return self
    }
    
    func alignment(_ edges: Alignment, value: CGFloat? = 0) -> Self {
        var align = self.zk_attribute.alignment ?? [:]
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
        self.zk_attribute.alignment = align
        return self
    }
    
    // 未完善
    func offset(x: CGFloat, y: CGFloat) -> Self {
        self.zk_attribute.offset = CGPoint(x: x, y: y)
        return self
    }
    
    // padding将封装一个containerview
    func padding(top: CGFloat? = nil, leading: CGFloat? = nil, bottom: CGFloat? = nil, trailing: CGFloat? = nil) -> Self {
        var mar = [Edge: CGFloat]()
        mar[.top] = top
        mar[.leading] = leading
        mar[.bottom] = bottom
        mar[.trailing] = trailing
        self.zk_attribute.padding = mar
        return self
    }
    
    @discardableResult func arrangeViews(@ViewBuilder _ content: ViewBuilder.ContentBlock) -> Self {
        let views = content()
        let base = self
        
        for view in views {
            let attribute = view.zk_attribute
            view.translatesAutoresizingMaskIntoConstraints = false
            var container = view
            if attribute.padding != nil || !attribute.offset.equalTo(.zero) {
                let paddingContainer = PaddingContainerView()
                paddingContainer.addContentView(view, padding: attribute.padding ?? [:], offset: attribute.offset)
                container = paddingContainer
            }
            
            container.translatesAutoresizingMaskIntoConstraints = false
            if let stack = base as? UIStackView {
                stack.addArrangedSubview(container)
                // 在stack中不用操心对齐问题
            } else {
                base.addSubview(container)
                
                let alignment = attribute.alignment ?? [:] // 不提供默认值，让外面传入
                // 对齐
                if let const = alignment[.centerY] {
                    container.centerYAnchor.constraint(equalTo: base.centerYAnchor, constant: const).isActive = true
                }
                if let const = alignment[.centerX] {
                    container.centerXAnchor.constraint(equalTo: base.centerXAnchor, constant: const).isActive = true
                }
                if let const = alignment[.leading] {
                    container.leadingAnchor.constraint(equalTo: base.leadingAnchor, constant: const).isActive = true
                }
                if let const = alignment[.trailing] {
                    container.trailingAnchor.constraint(equalTo: base.trailingAnchor, constant: const).isActive = true
                }
                if let const = alignment[.top] {
                    container.topAnchor.constraint(equalTo: base.topAnchor, constant: const).isActive = true
                }
                if let const = alignment[.bottom] {
                    container.bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: const).isActive = true
                }
            }
            
            if let si = attribute.width {
                if case .equalTo(let size) = si {
                    container.widthAnchor.constraint(equalToConstant: size).isActive = true
                } else if case .fillParent = si {
                    container.widthAnchor.constraint(equalTo: base.widthAnchor).isActive = true
                }
            }
            if let si = attribute.height {
                if case .equalTo(let size) = si {
                    container.heightAnchor.constraint(equalToConstant: size).isActive = true
                } else if case .fillParent = si {
                    container.heightAnchor.constraint(equalTo: base.heightAnchor).isActive = true
                }
            }
        }
        
        // on appear
        DispatchQueue.main.async { // [weak view] in
            for view in views {
                view.zk_attribute.onAppear?(view)
            }
        }
        return base
    }
}

internal class PaddingContainerView: UIView {
    func addContentView(_ content: UIView, padding: [Edge: CGFloat], offset: CGPoint = .zero) {
        self.contentOffset = offset
        self.addSubview(content)
        self.contentView = content
        if let paView = contentView?.superview as? PaddingContainerView {
            paView.removeFromSuperview()
        }
        
        content.translatesAutoresizingMaskIntoConstraints = false
        
        let offset: CGPoint = self.contentOffset
        let top = offset.y + (padding[.top] ?? 0)
        let bottom = offset.y - (padding[.bottom] ?? 0)
        let leading = offset.x + (padding[.leading] ?? 0)
        let trailing = offset.x - (padding[.trailing] ?? 0)
        
        content.topAnchor.constraint(equalTo: self.topAnchor, constant: top).isActive = true
        content.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom).isActive = true
        content.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading).isActive = true
        content.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailing).isActive = true
        
        self.resetContentKeyPathObservations {
            self.observe(obj: content, keyPath: \.isHidden)
        }
    }
    
    private var contentOffset: CGPoint = .zero
    private weak var contentView: UIView? = nil
    private var observeTokens = [NSKeyValueObservation]()
    private typealias KVOResultBuilder = ResultBuilder<NSKeyValueObservation>
    
    private func resetContentKeyPathObservations(@KVOResultBuilder _ content: KVOResultBuilder.ContentBlock) {
        self.observeTokens.removeAll()
        let kvo = content()
        observeTokens.append(contentsOf: kvo)
    }
    
    private func observe<T: UIView, Value>(obj: T, keyPath: WritableKeyPath<T, Value>) -> NSKeyValueObservation {
        let obs = obj.observe(keyPath, options: .new) { [weak self] view, change in
            if let newValue = change.newValue, var myself = self as? T {
                myself[keyPath: keyPath] = newValue
            }
        }
        return obs
    }
}
