//
//  ZKitModifier.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

///
///
///摘抄了一些常用属性，修改后返回self，达到链式调用的效果
///

public extension UIView {
    
    func backgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    func cornerRadius(_ cornerRadius: CGFloat) -> Self {
        self.layer.cornerRadius = cornerRadius
        return self
    }
    
    func clipped() -> Self {
        self.layer.masksToBounds = true
        return self
    }
    
    func borderColor(_ color: UIColor) -> Self {
        self.layer.borderColor = color.cgColor
        return self
    }
    
    func borderWidth(_ width: CGFloat) -> Self {
        self.layer.borderWidth = width >= 0 ? width : 0
        return self
    }
    
    func border(width: CGFloat, color: UIColor) -> Self {
        return self.borderWidth(width).borderColor(color)
    }
    
//    func store(in view: inout UIView?) -> Self {
//        view = self
//        return self
//    }
}

public extension UILabel {
    func text(_ text: String) -> Self {
        self.text = text
        return self
    }
    
    func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }
    
    func numberOfLines(_ lines: Int) -> Self {
        self.numberOfLines = lines
        return self
    }
    
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
}

public extension UIControl {
    
    typealias ActionBlock = () -> Void
    
    private enum AssociatedKey {
        static var blockKey: Int = 0
    }
    
    func action(for event: Event = .touchUpInside, _ action: @escaping ActionBlock) -> Self {
        self.zk_actionBlock = action
        self.addTarget(self, action: #selector(zk_selfTapAction), for: event)
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
        self.zk_actionBlock?()
    }
    
    func textAlignment(_ alignment: ContentHorizontalAlignment) -> Self {
        self.contentHorizontalAlignment = alignment
        return self
    }
}

public extension UIButton {
    func font(_ font: UIFont) -> Self {
        self.titleLabel?.font = font
        return self
    }
    
    // states
    func text(_ text: String, for state: UIControl.State = .normal) -> Self {
        self.setTitle(text, for: state)
        return self
    }
    
    func textColor(_ color: UIColor, for state: UIControl.State = .normal) -> Self {
        self.setTitleColor(color, for: state)
        return self
    }
}

public extension UIScrollView {
    func bounce(_ axis: NSLayoutConstraint.Axis) -> Self {
        if axis == .vertical {
            self.alwaysBounceVertical = true
        } else if axis == .horizontal {
            self.alwaysBounceHorizontal = true
        }
        return self
    }
    
    func pageEnabled(_ enabled: Bool) -> Self {
        self.isPagingEnabled = enabled
        return self
    }
    
    func contentOffsetObserve(handler: @escaping (CGPoint) -> Void) -> Self {
        self.zk_delegate.scrollDidScrollHandler = handler
        self.delegate = self.zk_delegate
        return self
    }
    
    func pageObserve(handler: @escaping (CGFloat) -> Void) -> Self {
        return self.contentOffsetObserve { [weak self] point in
            if let size = self?.frame.size.width, size > 0 {
                let page = point.x / size
                handler(page)
            }
        }
    }
    
    private var zk_delegate: Delegate {
        set {
            let obj = newValue
            objc_setAssociatedObject(self, &Delegate.attributeKey, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let obj = objc_getAssociatedObject(self, &Delegate.attributeKey) as? Delegate {
                return obj
            }
            let newone = Delegate()
            self.zk_delegate = newone
            return newone
        }
    }
    
    private class Delegate: NSObject, UIScrollViewDelegate {
        static var attributeKey: Int = 0
        var scrollDidScrollHandler: ((CGPoint) -> Void)?
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.scrollDidScrollHandler?(scrollView.contentOffset)
        }
    }
}

public extension UITextField {
    func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }
    
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
}

// MARK: State Observing

public extension UILabel {
    // stateText
    func text(binding stateText: Binding<String>) -> Self {
        stateText.wrapper.addObserver { [weak self] changed in
            self?.text = changed.new
        }
        return self
    }
}

public extension UIButton {
    func text(binding stateText: Binding<String>, for state: UIControl.State = .normal) -> Self {
        stateText.wrapper.addObserver { [weak self] changed in
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
        self.zk_textBlock?(self.text ?? "")
    }
    
    func text(binding text: Binding<String>) -> Self {
        self.addTarget(self, action: #selector(selfTextDidChanged), for: .allEditingEvents)
        let state = text.wrapper
        var shouldObserve = true
        self.zk_textBlock = { [weak state] text in
            shouldObserve = false
            state?.wrappedValue = text
            shouldObserve = true
        }
        state.addObserver { [weak self] changed in
            if shouldObserve {
                self?.text = changed.new
            }
        }
        return self
    }
    
    func borderStyle(_ style: BorderStyle) -> Self {
        self.borderStyle = style
        return self
    }
}
