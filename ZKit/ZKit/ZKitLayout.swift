//
//  ZKitLayout.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

extension UIView {
    
    func onAppear(_ action: @escaping OnAppearBlock) -> Self {
        self.zk_onAppearBlock = action
        return self
    }
    
    typealias OnAppearBlock = (UIView) -> Void
    var zk_onAppearBlock: OnAppearBlock? {
        set {
            let n = newValue
            objc_setAssociatedObject(self, &ZKit.AssociatedKey.onAppearKey, n, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let n = objc_getAssociatedObject(self, &ZKit.AssociatedKey.onAppearKey)
            return n as? OnAppearBlock
        }
    }
    
    private var zk_attribute: ZKit.Attribute {
        set {
            let obj = newValue
            objc_setAssociatedObject(self, &ZKit.AssociatedKey.attributeKey, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let obj = objc_getAssociatedObject(self, &ZKit.AssociatedKey.attributeKey) as? ZKit.Attribute {
                return obj
            }
            let newone = ZKit.Attribute()
            self.zk_attribute = newone
            return newone
        }
    }
    
    func frame(width: CGFloat? = nil, height: CGFloat? = nil, filledWidth: Bool = false, filledHeight: Bool = false) -> Self {
        let att = self.zk_attribute
        att.width = width
        att.height = height
        att.filledWidth = filledWidth
        att.filledHeight = filledHeight
        return self
    }
    
    func alignment(_ alignment: ZKit.Alignment? = .allEdges) -> Self {
        self.zk_attribute.alignment = alignment
        return self
    }
    
    func margin(top: CGFloat? = nil, leading: CGFloat? = nil, bottom: CGFloat? = nil, trailing: CGFloat? = nil) -> Self {
        var mar = [ZKit.Edges: CGFloat]()
        mar[.top] = top
        mar[.leading] = leading
        mar[.bottom] = bottom
        mar[.trailing] = trailing
        self.zk_attribute.margin = mar
        return self
    }

    @discardableResult func arrangeViews(@ZKit.ViewBuilder _ content: ZKit.ViewBuilder.ContentBlock) -> Self {
        let views = content()
        
        for view in views {
            let attribute = view.zk_attribute
            view.translatesAutoresizingMaskIntoConstraints = false
            var container = view
            if let pad = attribute.margin {
                let paddingContainer = ZKit.PaddingContainerView()
                paddingContainer.addContentView(view, padding: pad)
                container = paddingContainer
            }
            
            container.translatesAutoresizingMaskIntoConstraints = false
            if let stack = self as? UIStackView {
                stack.addArrangedSubview(container)
                // 在stack中不用操心对齐问题
            } else {
                self.addSubview(container)
                
                let alignment = attribute.alignment ?? .allEdges
                // 对齐
                if alignment.contains(.centerY) {
                    container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
                }
                if alignment.contains(.centerX) {
                    container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
                }
                if alignment.contains(.leading) {
                    container.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                }
                if alignment.contains(.trailing) {
                    container.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                }
                if alignment.contains(.top) {
                    container.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                }
                if alignment.contains(.bottom) {
                    container.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                }
            }
            
            if let width = attribute.width {
                container.widthAnchor.constraint(equalToConstant: width).isActive = true
            } else if attribute.filledWidth {
                container.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            }
            if let height = attribute.height {
                container.heightAnchor.constraint(equalToConstant: height).isActive = true
            } else if attribute.filledHeight {
                container.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
            }
        }
        
        // on appear
        DispatchQueue.main.async { // [weak view] in
            for view in views {
                view.zk_onAppearBlock?(view)
            }
        }
        return self
    }
}
