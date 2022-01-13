//
//  LazyFishModifier.swift
//  LazyFish
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

///
///
///摘抄了一些常用属性，修改后返回self，达到链式调用的效果
///
///
///

public protocol KeyPathBinding {
}

extension UIView: KeyPathBinding {
}

public extension KeyPathBinding where Self: UIView {
    func property<Value>(_ keyPath: WritableKeyPath<Self, Value>, binding: Binding<Value>?) -> Self {
        binding?.addObserver(target: self, observer: { [weak self] change in
            self?[keyPath: keyPath] = change.new
        })
        return self
    }
    
    func property<Value>(_ keyPath: WritableKeyPath<Self, Value>, value newValue: Value) -> Self {
        // self[keyPath: keyPath] = newValue
        // 收到警告？？？Cannot assign through subscript: 'self' is immutable
        var weakself = self as Self?
        weakself?[keyPath: keyPath] = newValue
        return self
    }
}

public extension UIView {
    
    func backgroundColor(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }
    
    func cornerRadius(_ cornerRadius: CGFloat) -> Self {
        layer.cornerRadius = cornerRadius
        return self
    }
    
    func clipped() -> Self {
        layer.masksToBounds = true
        return self
    }
    
    func clipped(_ clip: Bool) -> Self {
        layer.masksToBounds = clip
        return self
    }
    
    func borderColor(_ color: UIColor) -> Self {
        layer.borderColor = color.cgColor
        return self
    }
    
    func borderWidth(_ width: CGFloat) -> Self {
        layer.borderWidth = width >= 0 ? width : 0
        return self
    }
    
    func border(width: CGFloat, color: UIColor) -> Self {
        return borderWidth(width).borderColor(color)
    }
    
    func tintColor(_ color: UIColor) -> Self {
        tintColor = color
        return self
    }
    
//    func store(in view: inout UIView?) -> Self {
//        view = self
//        return self
//    }
}

public extension UILabel {
    func text(_ txt: String) -> Self {
        text = txt
        return self
    }
    
    func textColor(_ color: UIColor) -> Self {
        textColor = color
        return self
    }
    
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        textAlignment = alignment
        return self
    }
    
    func numberOfLines(_ lines: Int) -> Self {
        numberOfLines = lines
        return self
    }
    
    func font(_ fnt: UIFont) -> Self {
        font = fnt
        return self
    }
}

public extension UIControl {
    
    typealias ActionBlock = () -> Void
    
    private enum AssociatedKey {
        static var blockKey: Int = 0
    }
    
    func action(for event: Event = .touchUpInside, _ action: @escaping ActionBlock) -> Self {
        zk_actionBlock = action
        addTarget(self, action: #selector(zk_selfTapAction), for: event)
        return self
    }
    
    private var zk_actionBlock: ActionBlock? {
        set {
            let n = newValue
            objc_setAssociatedObject(self, &AssociatedKey.blockKey, n, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let n = objc_getAssociatedObject(self, &AssociatedKey.blockKey)
            return n as? ActionBlock
        }
    }
    
    @objc private func zk_selfTapAction() {
        zk_actionBlock?()
    }
    
    func textAlignment(_ alignment: ContentHorizontalAlignment) -> Self {
        contentHorizontalAlignment = alignment
        return self
    }
}

public extension UIButton {
    func font(_ font: UIFont) -> Self {
        titleLabel?.font = font
        return self
    }
    
    // states
    func text(_ text: String, for state: UIControl.State = .normal) -> Self {
        setTitle(text, for: state)
        return self
    }
    
    func textColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        setTitleColor(color, for: state)
        return self
    }
}

public extension UIScrollView {
    func bounce(_ axis: NSLayoutConstraint.Axis, bounce: Bool = true) -> Self {
        if axis == .vertical {
            alwaysBounceVertical = bounce
        } else if axis == .horizontal {
            alwaysBounceHorizontal = bounce
        }
        return self
    }
    
    func pageEnabled(_ enabled: Bool) -> Self {
        isPagingEnabled = enabled
        return self
    }
    
    func contentOffsetObserve(handler: @escaping (CGPoint) -> Void) -> Self {
        zk_scrollViewDelegate.scrollDidScrollHandler = handler
        delegate = zk_scrollViewDelegate
        return self
    }
    
    func pageObserve(handler: @escaping (CGFloat) -> Void) -> Self {
        return contentOffsetObserve { [weak self] point in
            if let size = self?.frame.size.width, size > 0 {
                let page = point.x / size
                handler(page)
            }
        }
    }
}

public extension UITextField {
    func textColor(_ color: UIColor) -> Self {
        textColor = color
        return self
    }
    
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        textAlignment = alignment
        return self
    }
    
    func font(_ fnt: UIFont) -> Self {
        font = fnt
        return self
    }
}

// MARK: State Observing

public extension UILabel {
    // stateText
    func text(binding stateText: Binding<String>?) -> Self {
        stateText?.addObserver(target: self) { [weak self] changed in
            self?.text = changed.new
        }
        return self
    }
}

public extension UIButton {
    func text(binding stateText: Binding<String>?, for state: UIControl.State = .normal) -> Self {
        stateText?.addObserver(target: self) { [weak self] changed in
            self?.setTitle(changed.new, for: state)
        }
        return self
    }
}

public extension UITextField {
    private typealias EditChangedBlock = (String) -> Void
    
    private enum AssociatedKey {
        static var editKey: Int = 0
    }
    
    private var zk_textBlock: EditChangedBlock? {
        set {
            let n = newValue
            objc_setAssociatedObject(self, &AssociatedKey.editKey, n, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let n = objc_getAssociatedObject(self, &AssociatedKey.editKey)
            return n as? EditChangedBlock
        }
    }
    
    @objc private func selfTextDidChanged() {
        zk_textBlock?(text ?? "")
    }
    
    func text(binding text: Binding<String>?, changed: @escaping (String) -> Void) -> Self {
        addTarget(self, action: #selector(selfTextDidChanged), for: .editingChanged)
        var shouldObserve = true
        zk_textBlock = { newText in
            shouldObserve = false
            changed(newText)
            shouldObserve = true
        }
        text?.addObserver(target: self) { [weak self] changed in
            if shouldObserve {
                self?.text = changed.new
            }
        }
        return self
    }
    
    func borderStyle(_ style: BorderStyle) -> Self {
        borderStyle = style
        return self
    }
}

public extension UISwitch {
    func isOn(_ on: Bool) -> Self {
        isOn = on
        return self
    }
    
    func isOn(binding: Binding<Bool>?, toggle: @escaping (Bool) -> Void) -> Self {
        binding?.addObserver(target: self) { [weak self] changed in
            self?.isOn = changed.new
        }
        let _ = self.action(for: .valueChanged) { [weak self] in
            toggle(self?.isOn ?? false)
        }
        return self
    }
}
