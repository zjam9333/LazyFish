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
        
        self.arrangeViews { [weak self] in
            if direction == .vertical {
                self?.showsHorizontalScrollIndicator = false
                let stack = UIStackView(axis: .vertical, distribution: .fill, alignment: .fill, spacing: 0, content: content)
                    .frame(filledWidth: true)
                    .alignment(.allEdges)
                stack
            } else {
                self?.showsVerticalScrollIndicator = false
                let stack = UIStackView(axis: .horizontal, distribution: .fill, alignment: .fill, spacing: 0, content: content)
                    .frame(filledHeight: true)
                    .alignment(.allEdges)
                stack
            }
        }
    }
}
