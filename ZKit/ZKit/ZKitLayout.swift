//
//  ZKitLayout.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

extension UIView {
    private var zk_attribute: ZKit.Attribute {
        set {
            let obj = newValue
            objc_setAssociatedObject(self, &ZKit.AssociatedKey.attributeKey, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let obj = objc_getAssociatedObject(self, &ZKit.AssociatedKey.attributeKey) as? ZKit.Attribute ?? ZKit.Attribute()
            self.zk_attribute = obj
            return obj
        }
    }
    
    func frame(width: CGFloat? = nil, height: CGFloat? = nil, filledWidth: Bool = false, filledHeight: Bool = false, alignment: ZKit.Alignment? = .allEdges) -> Self {
        let att = self.zk_attribute
        att.width = width
        att.height = height
        att.alignment = alignment
        att.filledWidth = filledWidth
        att.filledHeight = filledHeight
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

    @discardableResult func arrangeViews(@ZKitResultBuilder _ content: () -> [UIView]) -> Self {
        let views = content()
        for view in views {
            let attribute = view.zk_attribute
            view.translatesAutoresizingMaskIntoConstraints = false
            var container = view
            if let pad = attribute.margin {
                container = ZKit.PaddingContainerView()
                container.addSubview(view)
                
                view.topAnchor.constraint(equalTo: container.topAnchor, constant: pad[.top] ?? 0).isActive = true
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -(pad[.bottom] ?? 0)).isActive = true
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: pad[.leading] ?? 0).isActive = true
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -(pad[.trailing] ?? 0)).isActive = true
            }
            
            container.translatesAutoresizingMaskIntoConstraints = false
            if let stack = self as? UIStackView {
                stack.addArrangedSubview(container)
                // 在stack中不用操心对齐问题
            } else {
                self.addSubview(container)
                
                if let alignment = attribute.alignment {
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
            
            // on appear
            if let onapp = view.zk_onAppearBlock {
                DispatchQueue.main.async { // [weak view] in
                    onapp()
                }
            }
        }
        return self
    }
}
