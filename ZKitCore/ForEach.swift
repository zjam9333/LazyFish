//
//  ForEach.swift
//  ZKitCore
//
//  Created by zjj on 2021/10/26.
//

import Foundation
import UIKit

// TODO: for each 怎么实现刷新？
//public func ForEach<T>(_ array: Binding<[T]>, @ViewBuilder contents: ViewBuilder.ContentBlock = { [] }) -> [UIView] {
//    
//    return []
//}

public func ForEach<T>(_ models: Binding<[T]>, @ViewBuilder contents: @escaping (T) -> [UIView]) -> UIView {
    let container = ForEachView<T>()
    container.viewCreater = contents
    DispatchQueue.main.async {
        models.wrapper.addObserver { [weak container] changed in
            container?.reloadSubviews(changed.new)
        }
    }
    return container
}

private class ForEachView<T>: UIView {
    var viewCreater: ((T) -> [UIView])?
    
    func reloadSubviews(_ models: [T]) {
        let allSubviews = self.subviews
        for i in allSubviews {
            i.removeFromSuperview()
        }
        // 重新加载全部！！！如何优化？
        self.isHidden = models.isEmpty
        
        // 如果和stack有关，则拷贝stack的属性
        let superView = self.superview
        var superStack: UIStackView?
        if let stack = superView as? UIStackView {
            superStack = stack
        } else if let scroll = superView as? UIScrollView, let stack = scroll.internalLayoutStack {
            superStack = stack
            // internalLayoutStack定义在views extension UIScrollView中
        }
        if let superStack = superStack {
            let views = models.map { [weak self] m in
                UIView("container") {
                    self?.viewCreater?(m) ?? []
                }
            }
            // stack内foreach将再封一层stack，且参数一致
            self.arrangeViews {
                UIStackView(axis: superStack.axis, distribution: superStack.distribution, alignment: superStack.alignment, spacing: superStack.spacing) {
                    views
                }.alignment(.allEdges)
            }
        } else {
            let views = models.map { [weak self] m in
                UIView("container") {
                    self?.viewCreater?(m) ?? []
                }.alignment(.allEdges)
            }
            self.arrangeViews {
                views
            }
            // 不在stack内的views应该怎么排？？
        }
    }
}
