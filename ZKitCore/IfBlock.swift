//
//  ZKitIfBlock.swift
//  ZKit
//
//  Created by zjj on 2021/10/20.
//

import Foundation
import UIKit

public func IfBlock(_ present: Binding<Bool>, @ViewBuilder content: ViewBuilder.ContentBlock, contentElse: ViewBuilder.ContentBlock = { [] }) -> [UIView] {
    IfBlock(present, map: { a in
        return a
    }, contentIf: content, contentElse: contentElse)
}

public func IfBlock<T>(_ observe: Binding<T>, map: @escaping (T) -> Bool, @ViewBuilder contentIf: ViewBuilder.ContentBlock, @ViewBuilder contentElse: ViewBuilder.ContentBlock = { [] }) -> [UIView] {
    let viewsIf = contentIf()
    let viewsElse = contentElse()
    let all = viewsIf + viewsElse
    let allCount = all.count
    let ifCount = viewsIf.count
    for i in 0..<allCount {
        let vi = all[i]
        let isIf = i < ifCount
        observe.wrapper.addObserver { [weak vi] changed in
            let present = map(changed.new)
            vi?.isHidden = isIf ? !present : present
        }
    }
    return all
}

// MARK: IfBlockView与其他容器结合有bug
private func IfBlockNew<T>(_ observe: Binding<T>, map: @escaping (T) -> Bool, @ViewBuilder contentIf: ViewBuilder.ContentBlock, @ViewBuilder contentElse: ViewBuilder.ContentBlock = { [] }) -> [UIView] {
    let containerIf = IfBlockView()
    let containerElse = IfBlockView()
    containerIf.contentViews = contentIf()
    containerElse.contentViews = contentElse()
    observe.wrapper.addObserver { [weak containerIf, weak containerElse] changed in
        let present = map(changed.new)
        containerIf?.isHidden = !present
        containerElse?.isHidden = present
    }
    
    return [containerIf, containerElse]
}

private class IfBlockView: UIView {
    var contentViews: [UIView]?
    private var didBuildViews: Bool = false
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let arr = contentViews {
            if didBuildViews == false && self.superview != nil {
                self.createViews(arr)
                self.didBuildViews = true
            }
        }
    }
    
    private func createViews(_ views: [UIView]) {
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
            
            // stack内foreach将再封一层stack，且参数一致
            self.arrangeViews {
                UIStackView(axis: superStack.axis, distribution: superStack.distribution, alignment: superStack.alignment, spacing: superStack.spacing) {
                    views
                }.alignment(.allEdges)
            }
        } else {
            self.arrangeViews {
                views.map { vi in
                    vi.alignment(.allEdges)
                }
            }
            // 不在stack内的views应该怎么排？？
        }
    }
}
