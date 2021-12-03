//
//  ZKitViews.swift
//  ZKit
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
        self.arrangeViews(content)
    }
}

public extension UIView {
    convenience init(_ comment: String = "nothing", @ViewBuilder content: ViewBuilder.ContentBlock) {
        self.init()
        self.arrangeViews(content)
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
            self.scrollDidScrollHandler?(scrollView.contentOffset)
        }
    }
    
    convenience init(_ direction: NSLayoutConstraint.Axis = .vertical, spacing: CGFloat = 0, @ViewBuilder content: ViewBuilder.ContentBlock) {
        self.init()
        
        let views = content()
        if direction == .vertical {
            self.showsHorizontalScrollIndicator = false
        } else {
            self.showsVerticalScrollIndicator = false
        }
        self.arrangeViews {
            let stack = InternalLayoutStackView(axis: direction, distribution: .fill, alignment: .fill, spacing: spacing) {
                    views
                }
                .alignment(.allEdges)
            if direction == .vertical {
                _ = stack.frame(filledWidth: true)
            } else {
                _ = stack.frame(filledHeight: true)
            }
            stack
        }
    }
}
