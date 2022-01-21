//
//  BindingExtension.swift
//  LazyFishCore
//
//  Created by zjj on 2022/1/20.
//

import Foundation
import CoreGraphics

// MARK: Bool

extension Binding where Element: Equatable {
    public static func == (lhs: Binding<Element>, rhs: Binding<Element>) -> Binding<Bool> {
        return lhs.join(rhs) { ele, ele2 in
            return ele == ele2
        }
    }
    
    public static func == (lhs: Binding<Element>, rhs: Element) -> Binding<Bool> {
        return lhs.map { ele in
            return ele == rhs
        }
    }
    
    public static func != (lhs: Binding<Element>, rhs: Binding<Element>) -> Binding<Bool> {
        return lhs.join(rhs) { ele, ele2 in
            return ele != ele2
        }
    }
    
    public static func != (lhs: Binding<Element>, rhs: Element) -> Binding<Bool> {
        return lhs.map { ele in
            return ele != rhs
        }
    }
}

// MARK: math

extension Binding where Element == CGFloat {
    public static func + (lhs: Binding<Element>, rhs: Element) -> Binding<Element> {
        return lhs.map { a in
            return a + rhs
        }
    }
    public static func - (lhs: Binding<Element>, rhs: Element) -> Binding<Element> {
        return lhs.map { a in
            return a - rhs
        }
    }
    public static func * (lhs: Binding<Element>, rhs: Element) -> Binding<Element> {
        return lhs.map { a in
            return a * rhs
        }
    }
    public static func / (lhs: Binding<Element>, rhs: Element) -> Binding<Element> {
        return lhs.map { a in
            return a / rhs
        }
    }
    public static func + (lhs: Binding<Element>, rhs: Binding<Element>) -> Binding<Element> {
        return lhs.join(rhs)  { a, b in
            return a + b
        }
    }
    public static func - (lhs: Binding<Element>, rhs: Binding<Element>) -> Binding<Element> {
        return lhs.join(rhs)  { a, b in
            return a - b
        }
    }
    public static func * (lhs: Binding<Element>, rhs: Binding<Element>) -> Binding<Element> {
        return lhs.join(rhs)  { a, b in
            return a * b
        }
    }
    public static func / (lhs: Binding<Element>, rhs: Binding<Element>) -> Binding<Element> {
        return lhs.join(rhs)  { a, b in
            return a / b
        }
    }
}
