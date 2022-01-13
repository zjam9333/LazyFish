//
//  LazyFishLayout.swift
//  LazyFish
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

fileprivate struct Layout {
    static func alignSubview(_ view: UIView, subview: UIView, alignment: [Edge: CGFloat]) {
        // 对齐
        if let const = alignment[.centerY] {
            subview.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: const).isActive = true
        }
        if let const = alignment[.centerX] {
            subview.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: const).isActive = true
        }
        if let const = alignment[.leading] {
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: const).isActive = true
        }
        if let const = alignment[.trailing] {
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: const).isActive = true
        }
        if let const = alignment[.top] {
            subview.topAnchor.constraint(equalTo: view.topAnchor, constant: const).isActive = true
        }
        if let const = alignment[.bottom] {
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: const).isActive = true
        }
    }
    
    static func containerPaddingIfNeed(_ view: UIView, padding: EdgeValuePair, offset: CGPoint) -> UIView {
        if padding.isEmpty && offset == .zero {
            return view
        }
        let paddingContainer = PaddingContainerView()
        paddingContainer.addContentView(view, padding: padding, offset: offset)
        return paddingContainer
    }
    
    static func sizeFill(_ view: UIView, width: SizeFill?, height: SizeFill?, target: UIView) {
        if let targetSuper = target as? FakeInternalContainer {
            targetSuper.excuteActionWhileMoveToWindow { [weak view] in
                // 如果一个view有window，那么一定有superview？
                if let superSuperView = targetSuper.seekTrullyContainer(), let view = view {
                    private_sizeFill(view, width: width, height: height, target: superSuperView)
                }
            }
        } else {
            private_sizeFill(view, width: width, height: height, target: target)
        }
    }
    
    private static func private_sizeFill(_ view: UIView, width: SizeFill?, height: SizeFill?, target: UIView) {
        guard view.isDescendant(of: target) else {
            return
        }
        if let si = width {
            if case .equalTo(let size) = si {
                view.widthAnchor.constraint(equalToConstant: size).isActive = true
            } else if case .fillParent(let mul, let con) = si {
                view.widthAnchor.constraint(equalTo: target.widthAnchor, multiplier: mul, constant: con).isActive = true
            }
        }
        if let si = height {
            if case .equalTo(let size) = si {
                view.heightAnchor.constraint(equalToConstant: size).isActive = true
            } else if case .fillParent(let mul, let con) = si {
                view.heightAnchor.constraint(equalTo: target.heightAnchor, multiplier: mul, constant: con).isActive = true
            }
        }
    }
}

public extension UIView {
    
    @discardableResult func arrangeViews(ignoreAlignments: Bool = false, @ViewBuilder _ content: ViewBuilder.ContentBlock) -> Self {
        let views = content()
        var allActionsOnAppear = [() -> Void]()
        
        for view in views {
            let attribute = Attribute.attribute(from: view)
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
            let container = Layout.containerPaddingIfNeed(view, padding: padding, offset: offset)
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
                    Layout.alignSubview(self, subview: container, alignment: alignment)
                }
            }
            
            Layout.sizeFill(container, width: widthFill, height: heightFill, target: self)
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
