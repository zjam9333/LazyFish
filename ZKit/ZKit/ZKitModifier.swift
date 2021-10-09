//
//  ZKitModifier.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

extension UIView {
    typealias ActionBlock = () -> Void
    
    fileprivate enum AssociatedKey {
        static var blockKey: Int = 0
        static var onAppearKey: Int = 0
        static var onDisapperaKey: Int = 0
    }
    
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
    
//    func store(in view: inout UIView?) -> Self {
//        view = self
//        return self
//    }
    
    func onAppear(_ action: @escaping () -> Void) -> Self {
        self.zk_onAppearBlock = action
        return self
    }
    
    typealias OnAppearBlock = () -> Void
    var zk_onAppearBlock: OnAppearBlock? {
        set {
            let n = newValue
            objc_setAssociatedObject(self, &AssociatedKey.onAppearKey, n, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let n = objc_getAssociatedObject(self, &AssociatedKey.onAppearKey)
            return n as? OnAppearBlock
        }
    }
}

extension UILabel {
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

extension UIControl {
    
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
}

extension UIButton {
    func text(_ text: String) -> Self {
        self.setTitle(text, for: .normal)
        return self
    }
    
    func textColor(_ color: UIColor) -> Self {
        self.setTitleColor(color, for: .normal)
        return self
    }
    
    func font(_ font: UIFont) -> Self {
        self.titleLabel?.font = font
        return self
    }
    
    // states
    func text(_ text: String, for state: UIControl.State) -> Self {
        self.setTitle(text, for: state)
        return self
    }
    
    func textColor(_ color: UIColor, for state: UIControl.State) -> Self {
        self.setTitleColor(color, for: state)
        return self
    }
}


