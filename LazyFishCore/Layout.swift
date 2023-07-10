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
    
    static func sizeFill(_ view: UIView, width: SizeFill?, height: SizeFill?) {
        private_sizeFill(view, width: width, height: height)
    }
    
    private static func private_sizeFill(_ view: UIView, width: SizeFill?, height: SizeFill?) {
        
        func dimensionAnchor(view: UIView, di: SizeFill.Dimension) -> NSLayoutDimension {
            switch di {
            case .x:
                return view.widthAnchor
            case .y:
                return view.heightAnchor
            }
        }
        
        func fillDimension(view: UIView, di: SizeFill.Dimension, sizefill: SizeFill) {
            switch sizefill {
            case .unknown:
                break
            case .equal(let valueBind):
                switch valueBind {
                case .constant(let value):
                    dimensionAnchor(view: view, di: di).constraint(equalToConstant: value).isActive = true
                case .binding(let bind):
                    let constraint = dimensionAnchor(view: view, di: di).constraint(equalToConstant: 0)
                    constraint.isActive = true
                    bind.addObserver(target: view) { [weak constraint] change in
                        constraint?.constant = change.new
                    }
                }
            }
        }
        
        if let si = width {
            fillDimension(view: view, di: .x, sizefill: si)
        }
        if let si = height {
            fillDimension(view: view, di: .y, sizefill: si)
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
                case .onAppear(let block):
                    allActionsOnAppear.append {
                        block?(view)
                    }
                }
            }
            let container = view // Layout.containerPaddingIfNeed(view, padding: padding, offset: offset)
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
            
            Layout.sizeFill(container, width: widthFill, height: heightFill)
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
