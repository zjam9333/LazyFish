//
//  ZKitIfBlock.swift
//  ZKit
//
//  Created by zjj on 2021/10/20.
//

import Foundation
import UIKit

func IfBlock(_ present: ZKit.State<Bool>, @ZKit.ViewBuilder content: ZKit.ViewBuilder.ContentBlock, contentElse: ZKit.ViewBuilder.ContentBlock = { [] }) -> [UIView] {
    IfBlock(present, map: { a in
        return a
    }, contentIf: content, contentElse: contentElse)
}

func IfBlock<T>(_ observe: ZKit.State<T>, map: @escaping (T) -> Bool, @ZKit.ViewBuilder contentIf: ZKit.ViewBuilder.ContentBlock, @ZKit.ViewBuilder contentElse: ZKit.ViewBuilder.ContentBlock = { [] }) -> [UIView] {
    let viewsIf = contentIf()
    let viewsElse = contentElse()
    let all = viewsIf + viewsElse
    let allCount = all.count
    let ifCount = viewsIf.count
    for i in 0..<allCount {
        let vi = all[i]
        let isIf = i < ifCount
        observe.addObserver { [weak vi] changed in
            let present = map(changed.new)
            vi?.isHidden = isIf ? !present : present
        }
    }
    return all
}
