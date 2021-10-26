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
    convenience init(_ direction: NSLayoutConstraint.Axis = .vertical, @ViewBuilder content: ViewBuilder.ContentBlock) {
        self.init()
        
        let views = content()
        let fakeViews = views.map { vi -> UIView in
            let newView = UIView()
            return newView
        }
        // 此fakeviews仅用于排版
        self.arrangeViews { [weak self] in
            if direction == .vertical {
                self?.showsHorizontalScrollIndicator = false
                let stack = UIStackView(axis: .vertical, distribution: .fill, alignment: .fill, spacing: 0) {
                        fakeViews
                    }
                    .frame(filledWidth: true)
                    .alignment(.allEdges)
                stack.isHidden = true
                stack
            } else {
                self?.showsVerticalScrollIndicator = false
                let stack = UIStackView(axis: .horizontal, distribution: .fill, alignment: .fill, spacing: 0) {
                        fakeViews
                    }
                    .frame(filledHeight: true)
                    .alignment(.allEdges)
                stack.isHidden = true
                stack
            }
        }
        for a in views {
            a.zk_attribute.alignment = nil
        }
        self.arrangeViews {
            views
        }
        for (a, b) in zip(views, fakeViews) {
            var aview = a
            if let p = aview.superview as? PaddingContainerView {
                aview = p
            }
            aview.topAnchor.constraint(equalTo: b.topAnchor).isActive = true
            aview.bottomAnchor.constraint(equalTo: b.bottomAnchor).isActive = true
            aview.leadingAnchor.constraint(equalTo: b.leadingAnchor).isActive = true
            aview.trailingAnchor.constraint(equalTo: b.trailingAnchor).isActive = true
        }
    }
}
