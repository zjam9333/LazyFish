//
//  LazyFishViews.swift
//  LazyFish
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

public extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis, distribution: Distribution = .fill, alignment: Alignment = .fill, spacing: CGFloat = 0, @ViewBuilder content: ViewBuilder.ContentBlock) {
        self.init()
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        arrangeViews(content)
    }
}

public extension UIView {
    convenience init(_ comment: String = "nothing", @ViewBuilder content: ViewBuilder.ContentBlock) {
        self.init()
        arrangeViews(content)
    }
}

public extension UILabel {
    convenience init(_ text: String) {
        self.init()
        _ = self.text(text)
    }
}

public extension UIButton {
    convenience init(_ text: String) {
        self.init()
        _ = self.text(text)
    }
}

public extension UIScrollView {
    internal var zk_scrollViewDelegate: Delegate {
        set {
            let obj = newValue
            objc_setAssociatedObject(self, &Delegate.attributeKey, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let obj = objc_getAssociatedObject(self, &Delegate.attributeKey) as? Delegate {
                return obj
            }
            let newone = Delegate()
            self.zk_scrollViewDelegate = newone
            return newone
        }
    }
    
    internal class Delegate: NSObject, UIScrollViewDelegate {
        static var attributeKey: Int = 0
        var scrollDidScrollHandler: ((CGPoint) -> Void)?
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollDidScrollHandler?(scrollView.contentOffset)
        }
    }
    
    convenience init(_ direction: NSLayoutConstraint.Axis = .vertical, spacing: CGFloat = 0, @ViewBuilder content: ViewBuilder.ContentBlock) {
        self.init()
        
        let views = content()
        if direction == .vertical {
            showsHorizontalScrollIndicator = false
        } else {
            showsVerticalScrollIndicator = false
        }
        
        let stack = InternalLayoutStackView(axis: direction, distribution: .fill, alignment: .fill, spacing: spacing) {
                views
            }
        self.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        if direction == .vertical {
            self.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        } else {
            self.heightAnchor.constraint(equalTo: stack.heightAnchor).isActive = true
        }
        self.topAnchor.constraint(equalTo: stack.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: stack.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true
    }
}
