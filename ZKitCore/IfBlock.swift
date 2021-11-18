//
//  ZKitIfBlock.swift
//  ZKit
//
//  Created by zjj on 2021/10/20.
//

import Foundation
import UIKit

public func IfBlock(_ present: Binding<Bool>, @ViewBuilder content: ViewBuilder.ContentBlock, @ViewBuilder contentElse: ViewBuilder.ContentBlock = { [] }) -> [UIView] {
    IfBlock(present, map: { a in
        return a
    }, contentIf: content, contentElse: contentElse)
}

public func IfBlock<T>(_ observe: Binding<T>, map: @escaping (T) -> Bool, @ViewBuilder contentIf: ViewBuilder.ContentBlock, @ViewBuilder contentElse: ViewBuilder.ContentBlock = { [] }) -> [UIView] {
    let viewsIf = contentIf()
    let viewsElse = contentElse()
    let ifview = IfBlockView(ifBlockContents: viewsIf)
    let elseview = IfBlockView(ifBlockContents: viewsElse)
    if ifview == nil && elseview == nil {
        return []
    }
    observe.wrapper.addObserver { [weak ifview, weak elseview] changed in
        let present = map(changed.new)
        ifview?.isHidden = !present
        elseview?.isHidden = present
    }
    var views = [UIView]()
    if let ifview = ifview {
        views.append(ifview)
    }
    if let elseview = elseview {
        views.append(elseview)
    }
    return views
}

private class IfBlockView: UIView {
    
    private var actionWhileMoveToSuperview: [(UIView) -> Void] = []
    func appendActionForDidMoveToSuperview(_ action: @escaping (UIView) -> Void) {
        self.actionWhileMoveToSuperview.append(action)
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let scr = self.superview {
            for i in actionWhileMoveToSuperview {
                i(scr)
            }
            self.actionWhileMoveToSuperview.removeAll()
        }
    }
    
    convenience init?(ifBlockContents contents: [UIView]) {
        if contents.isEmpty {
            return nil
        }
        self.init()
        self.appendActionForDidMoveToSuperview { [weak self] superview in
            if let superStack = superview as? UIStackView {
                self?.arrangeViews {
                    UIStackView(axis: superStack.axis, distribution: superStack.distribution, alignment: superStack.alignment, spacing: superStack.spacing) {
                        contents
                    }.alignment(.allEdges)
                }
            } else {
                self?.arrangeViews {
                    contents
                }
            }
        }
    }
}
