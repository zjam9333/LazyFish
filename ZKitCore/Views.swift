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

public extension UIScrollView {
    private class HiddenLayoutView: UIView {
        private var observeTokens = [NSKeyValueObservation]()
        func observeViewHidden(_ view: UIView) {
            if view != self {
                let token = view.observe(\.isHidden, options: .new) { [weak self] view, changed in
                    self?.isHidden = changed.newValue ?? false
                }
                self.observeTokens.append(token)
            }
        }
    }
    
    convenience init(_ direction: NSLayoutConstraint.Axis = .vertical, spacing: CGFloat = 0, @ViewBuilder content: ViewBuilder.ContentBlock) {
        self.init()
        
        let views = content()
        let fakeViews = views.map { vi -> HiddenLayoutView in
            let newView = HiddenLayoutView()
            return newView
        }
        if direction == .vertical {
            self.showsHorizontalScrollIndicator = false
        } else {
            self.showsVerticalScrollIndicator = false
        }
        // 此fakeviews仅用于排版
        self.arrangeViews {
            let stack = UIStackView(axis: direction, distribution: .fill, alignment: .fill, spacing: spacing) {
                    fakeViews
                }
                .alignment(.allEdges)
            if direction == .vertical {
                _ = stack.frame(filledWidth: true)
            } else {
                _ = stack.frame(filledHeight: true)
            }
            stack.isHidden = true
            stack
        }
        
        // 真正的views添加在scrollview里，不直接排版，仅与fakeviews对齐
        self.arrangeViews(ignoreAlignments: true) {
            views
        }
        for (a, b) in zip(views, fakeViews) {
            var aview = a
            if let p = aview.superview as? PaddingContainerView {
                aview = p
            }
            b.observeViewHidden(a)
            aview.topAnchor.constraint(equalTo: b.topAnchor).isActive = true
            aview.bottomAnchor.constraint(equalTo: b.bottomAnchor).isActive = true
            aview.leadingAnchor.constraint(equalTo: b.leadingAnchor).isActive = true
            aview.trailingAnchor.constraint(equalTo: b.trailingAnchor).isActive = true
        }
    }
}
