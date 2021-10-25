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
