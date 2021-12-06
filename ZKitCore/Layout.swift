//
//  ZKitLayout.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

public extension UIView {
    internal func zk_alignSubview(_ subview: UIView, alignment: [Edge: CGFloat]) {
        // 对齐
        if let const = alignment[.centerY] {
            subview.centerYAnchor.constraint(equalTo: centerYAnchor, constant: const).isActive = true
        }
        if let const = alignment[.centerX] {
            subview.centerXAnchor.constraint(equalTo: centerXAnchor, constant: const).isActive = true
        }
        if let const = alignment[.leading] {
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: const).isActive = true
        }
        if let const = alignment[.trailing] {
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: const).isActive = true
        }
        if let const = alignment[.top] {
            subview.topAnchor.constraint(equalTo: topAnchor, constant: const).isActive = true
        }
        if let const = alignment[.bottom] {
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: const).isActive = true
        }
    }
    
    internal func zk_containerPaddingIfNeed(padding: EdgeValuePair, offset: CGPoint) -> UIView {
        if padding.isEmpty && offset == .zero {
            return self
        }
        let paddingContainer = PaddingContainerView()
        paddingContainer.addContentView(self, padding: padding, offset: offset)
        return paddingContainer
    }
    
    internal func old_descre_zk_containerPaddingIfNeed(attributes: [Attribute._Attribute]) -> UIView {
        var paddingView = self
        for i in attributes {
            switch i {
            case .padding(let pad):
                let paddingContainer = PaddingContainerView()
                paddingContainer.addContentView(paddingView, padding: pad)
                paddingView = paddingContainer
            case .offset(let point):
                let paddingContainer = PaddingContainerView()
                paddingContainer.addContentView(paddingView, offset: point)
                paddingView = paddingContainer
            default:
                continue
            }
        }
        return paddingView
    }
    
    internal func zk_sizeFill(width: SizeFill?, height: SizeFill?, target: UIView) {
        if let targetSuper = target as? FakeInternalContainer {
            targetSuper.excuteActionWhileMoveToWindow { [weak self] in
                // 如果一个view有window，那么一定有superview？
                if let superSuperView = targetSuper.seekTrullyContainer() {
                    self?.private_zk_sizeFill(width: width, height: height, target: superSuperView)
                }
            }
        } else {
            private_zk_sizeFill(width: width, height: height, target: target)
        }
    }
    
    private func private_zk_sizeFill(width: SizeFill?, height: SizeFill?, target: UIView) {
        guard isDescendant(of: target) else {
            return
        }
        if let si = width {
            if case .equalTo(let size) = si {
                widthAnchor.constraint(equalToConstant: size).isActive = true
            } else if case .fillParent(let mul, let con) = si {
                widthAnchor.constraint(equalTo: target.widthAnchor, multiplier: mul, constant: con).isActive = true
            }
        }
        if let si = height {
            if case .equalTo(let size) = si {
                heightAnchor.constraint(equalToConstant: size).isActive = true
            } else if case .fillParent(let mul, let con) = si {
                heightAnchor.constraint(equalTo: target.heightAnchor, multiplier: mul, constant: con).isActive = true
            }
        }
    }
}

public extension UIView {
    
    @discardableResult func arrangeViews(ignoreAlignments: Bool = false, @ViewBuilder _ content: ViewBuilder.ContentBlock) -> Self {
        let views = content()
        var allActionsOnAppear = [() -> Void]()
        
        for view in views {
            let attribute = view.zk_attribute
            var alignment: EdgeValuePair = [:]
            var widthFill: SizeFill?
            var heightFill: SizeFill?
            var padding = EdgeValuePair()
            var offset = CGPoint.zero
            for i in attribute.attrs {
                switch i {
                case .width(let w):
                    widthFill = w
                case .height(let h):
                    heightFill = h
                case .alignment(let ali):
                    for (k, v) in ali {
                        alignment[k] = v
                    }
                case .padding(let pad):
                    for (k, v) in pad {
                        padding[k] = v
                    }
                case .offset(let point):
                    offset = point
                case .onAppear(let block):
                    allActionsOnAppear.append {
                        block?(view)
                    }
                }
            }
            let container = view.zk_containerPaddingIfNeed(padding: padding, offset: offset)
            container.translatesAutoresizingMaskIntoConstraints = false
            if let stack = self as? UIStackView {
                stack.addArrangedSubview(container)
                // 针对stackview作为superview的IfBlock、ForEach等FakeInternalContainer
                if let fakeContainer = container as? FakeInternalContainer {
                    fakeContainer.didAddToSuperStackView(stack)
                }
            } else {
                addSubview(container)
                if ignoreAlignments == false && !alignment.isEmpty {
                    zk_alignSubview(container, alignment: alignment)
                }
            }
            
            container.zk_sizeFill(width: widthFill, height: heightFill, target: self)
        }
        
        for action in allActionsOnAppear {
            action()
        }
        
        return self
    }
    
    // MARK: OVERLAY & BACKGROUND
    
    @discardableResult private func overlay(@ViewBuilder _ content: ViewBuilder.ContentBlock) -> Self {
        return self
    }
    
    @discardableResult private func background(@ViewBuilder _ content: ViewBuilder.ContentBlock) -> Self {
        return self
    }
}
