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
    
    internal class InternalLayoutStackView: UIStackView {
        var superScrollView: UIScrollView? {
            return self.superview as? UIScrollView
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

extension UITableView {
    private class DataSourceDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 10
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.textLabel?.text = "\(indexPath.section)"
            return cell
        }
        
        static var attributeKey: Int = 0
    }
}

