//
//  ZKitResultBuilder.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

@resultBuilder
enum ZKitResultBuilder {
    static func buildBlock(_ components: [UIView]...) -> [UIView] {
        let res = components.flatMap { r in
            return r
        }
        return res
    }
    
    static func buildOptional<T>(_ component: [T]?) -> [UIView] {
        return []
    }
    
    static func buildExpression(_ expression: UIView) -> [UIView] {
        return [expression]
    }
    
    static func buildExpression(_ expression: UIView?) -> [UIView] {
        if let v = expression {
            return [v]
        }
        return []
    }
    
    static func buildExpression(_ expression: Void) -> [UIView] {
        return []
    }
    static func buildExpression(_ expression: Void?) -> [UIView] {
        return []
    }
    
    static func buildArray(_ components: [[UIView]]) -> [UIView] {
        let res = components.flatMap { r in
            return r
        }
        return res
    }
    
    static func buildEither(first component: [UIView]) -> [UIView] {
        return component
    }
    
    static func buildEither(second component: [UIView]) -> [UIView] {
        return component
    }
}
