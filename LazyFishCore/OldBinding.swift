//
//  OldBinding.swift
//  LazyFishCore
//
//  Created by zjj on 2023/8/16.
//

import Foundation

@dynamicMemberLookup
public class OldBinding<Element>: CustomStringConvertible, CustomDebugStringConvertible {
    
    internal var _currentValueGetter: () -> Element
    public func currentValue() -> Element {
        return _currentValueGetter()
    }
    
    public var description: String {
        return "\(currentValue())"
    }
    
    public var debugDescription: String {
        return "\(currentValue())"
    }
    
    private weak var wrapper: State<Element>?
    
    public static func constant(value: Element) -> OldBinding<Element> {
        return .init(wrapper: nil, currentValue: value)
    }
    
    public init(wrapper: State<Element>?, currentValue: @escaping @autoclosure () -> Element) {
        self.wrapper = wrapper
        self._currentValueGetter = currentValue
    }
    
    // 这个可以直接访问Element的properties！！
    public subscript<Value>(dynamicMember keyPath: KeyPath<Element, Value>) -> OldBinding<Value> {
        get {
            return self.map { ele in
                return ele[keyPath: keyPath]
            }
        }
    }
    
    public func addObserver(target: AnyObject?, observer: @escaping Changed<Element>.ObserverHandler) {
        guard let wrapper = wrapper else {
            let currentVal = currentValue()
            observer(.init(old: currentVal, new: currentVal))
            return
        }
        wrapper.addObserver(target: target) { changed in
            observer(changed)
        }
    }
    
    public func map<ResultElement>(_ transform: @escaping (Element) -> ResultElement) -> OldBinding<ResultElement> {
        let bindMap = Map<Element, ResultElement>(source: self, map: transform)
        return bindMap
    }
    
    public func join<OtherElement>(_ other: OldBinding<OtherElement>) -> OldBinding<(Element, OtherElement)> {
        let bindJoin = Join<Element, OtherElement>(self, with: other)
        return bindJoin
    }
    
    public func join<OtherElement, ResultElement>(_ other: OldBinding<OtherElement>, transform: @escaping (Element, OtherElement) -> ResultElement) -> OldBinding<ResultElement> {
        let joinMap = join(other).map(transform)
        return joinMap
    }
    
    public func zip<OtherElement, ResultElement>(_ other: OldBinding<OtherElement>, transform: @escaping (Element, OtherElement) -> ResultElement) -> OldBinding<ResultElement> {
        let joinMap = Zip<Element, OtherElement>(self, with: other).map(transform)
        return joinMap
    }
}

extension OldBinding {
    private class Map<SourceElement, ResultElement>: OldBinding<ResultElement> {
        var source: OldBinding<SourceElement>
        var map: (SourceElement) -> ResultElement
        init(source: OldBinding<SourceElement>, map: @escaping (SourceElement) -> ResultElement) {
            self.source = source
            self.map = map
            super.init(wrapper: nil, currentValue: map(source.currentValue()))
        }
        
        public override func addObserver(target: AnyObject?, observer: @escaping Changed<ResultElement>.ObserverHandler) {
            let map = self.map
            source.addObserver(target: target) { changed in
                let changedMap = Changed<ResultElement>(old: map(changed.old), new: map(changed.new))
                observer(changedMap)
            }
        }
    }
    
    private class Join<S1, S2>: OldBinding<(S1, S2)> {
        var source1: OldBinding<S1>
        var source2: OldBinding<S2>
        init(_ source1: OldBinding<S1>, with source2: OldBinding<S2>) {
            self.source1 = source1
            self.source2 = source2
            super.init(wrapper: nil, currentValue: (source1.currentValue(), source2.currentValue()))
        }
        
        public override func addObserver(target: AnyObject?, observer: @escaping Changed<(S1, S2)>.ObserverHandler) {
            var c1: Changed<S1>?
            var c2: Changed<S2>?
            let shouldClean = (self as? Zip<S1, S2>) != nil
            let performChanges = {
                if let c1obj = c1, let c2obj = c2 {
                    if shouldClean {
                        c1 = nil
                        c2 = nil
                    }
                    let changedAll = Changed<(S1, S2)>(old: (c1obj.old, c2obj.old), new: (c1obj.new, c2obj.new))
                    observer(changedAll)
                }
            }
            source1.addObserver(target: target) { change in
                c1 = change
                performChanges()
            }
            source2.addObserver(target: target) { change in
                c2 = change
                performChanges()
            }
        }
    }
    
    /// The Zip 要求全部元素都变化才打包发送
    private class Zip<S1, S2>: Join<S1, S2> {
    }
}

// MARK: Bool

extension OldBinding where Element: Equatable {
    public static func == (lhs: OldBinding<Element>, rhs: OldBinding<Element>) -> OldBinding<Bool> {
        return lhs.join(rhs) { ele, ele2 in
            return ele == ele2
        }
    }
    
    public static func == (lhs: OldBinding<Element>, rhs: Element) -> OldBinding<Bool> {
        return lhs.map { ele in
            return ele == rhs
        }
    }
    
    public static func != (lhs: OldBinding<Element>, rhs: OldBinding<Element>) -> OldBinding<Bool> {
        return lhs.join(rhs) { ele, ele2 in
            return ele != ele2
        }
    }
    
    public static func != (lhs: OldBinding<Element>, rhs: Element) -> OldBinding<Bool> {
        return lhs.map { ele in
            return ele != rhs
        }
    }
}

// MARK: math

extension OldBinding where Element: BinaryFloatingPoint {
    public static func + (lhs: OldBinding<Element>, rhs: Element) -> OldBinding<Element> {
        return lhs.map { a in
            return a + rhs
        }
    }
    public static func - (lhs: OldBinding<Element>, rhs: Element) -> OldBinding<Element> {
        return lhs.map { a in
            return a - rhs
        }
    }
    public static func * (lhs: OldBinding<Element>, rhs: Element) -> OldBinding<Element> {
        return lhs.map { a in
            return a * rhs
        }
    }
    public static func / (lhs: OldBinding<Element>, rhs: Element) -> OldBinding<Element> {
        return lhs.map { a in
            return a / rhs
        }
    }
    public static func + (lhs: OldBinding<Element>, rhs: OldBinding<Element>) -> OldBinding<Element> {
        return lhs.join(rhs)  { a, b in
            return a + b
        }
    }
    public static func - (lhs: OldBinding<Element>, rhs: OldBinding<Element>) -> OldBinding<Element> {
        return lhs.join(rhs)  { a, b in
            return a - b
        }
    }
    public static func * (lhs: OldBinding<Element>, rhs: OldBinding<Element>) -> OldBinding<Element> {
        return lhs.join(rhs)  { a, b in
            return a * b
        }
    }
    public static func / (lhs: OldBinding<Element>, rhs: OldBinding<Element>) -> OldBinding<Element> {
        return lhs.join(rhs)  { a, b in
            return a / b
        }
    }
}

extension OldBinding where Element: Comparable {
    public static func < (lhs: OldBinding, rhs: Element) -> OldBinding<Bool> {
        return lhs.map { ele in
            return ele < rhs
        }
    }

    public  static func < (lhs: OldBinding, rhs: OldBinding) -> OldBinding<Bool> {
        return lhs.join(rhs) { ele1, ele2 in
            return ele1 < ele2
        }
    }

    public static func > (lhs: OldBinding, rhs: Element) -> OldBinding<Bool> {
        return lhs.map { ele in
            return ele > rhs
        }
    }

    public static func > (lhs: OldBinding, rhs: OldBinding) -> OldBinding<Bool> {
        return lhs.join(rhs) { ele1, ele2 in
            return ele1 > ele2
        }
    }
}
