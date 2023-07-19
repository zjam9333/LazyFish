//
//  LazyFishArrayBuilder.swift
//  LazyFish
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

public typealias ViewBuilder = ArrayBuilder<UIView>
public typealias LayoutBuilder = ArrayBuilder<NSLayoutConstraint>

@_functionBuilder public struct ArrayBuilder<MyReturnType> {
    // MARK: 组合全部表达式的返回值
    public static func buildBlock(_ components: [MyReturnType]...) -> [MyReturnType] {
        let res = components.flatMap { r in
            return r
        }
        return res
    }
}

public extension ArrayBuilder {
    // MARK: 处理空白block
    static func buildOptional<T>(_ component: [T]?) -> [MyReturnType] {
        return []
    }
    
    // MARK: 处理不包含else的if语句
    static func buildOptional(_ component: [MyReturnType]?) -> [MyReturnType] {
        if let v = component {
            return v
        }
        return []
    }
    
    // MARK: 处理每一行表达式的返回值
    static func buildExpression(_ expression: MyReturnType) -> [MyReturnType] {
        return [expression]
    }
    
    static func buildExpression(_ expression: MyReturnType?) -> [MyReturnType] {
        if let v = expression {
            return [v]
        }
        return []
    }
    
    static func buildExpression(_ expression: Void) -> [MyReturnType] {
        return []
    }
    static func buildExpression(_ expression: Void?) -> [MyReturnType] {
        return []
    }
    
    static func buildExpression(_ expression: [MyReturnType]) -> [MyReturnType] {
        return expression
    }
    
    // MARK: Available API
    // 好像不写也可以支持 if #available(iOS xxxx, *)
//    static func buildLimitedAvailability(_ component: [MyReturnType]) -> [MyReturnType] {
//        return component
//    }
    
    // MARK: 处理for循环
    static func buildArray(_ components: [[MyReturnType]]) -> [MyReturnType] {
        let res = components.flatMap { r in
            return r
        }
        return res
    }
    
    // MARK: 处理if...else...（必须包含else)
    static func buildEither(first component: [MyReturnType]) -> [MyReturnType] {
        return component
    }
    
    static func buildEither(second component: [MyReturnType]) -> [MyReturnType] {
        return component
    }
}
