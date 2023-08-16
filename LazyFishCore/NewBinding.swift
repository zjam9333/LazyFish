//
//  Binding.swift
//  LazyFishCore
//
//  Created by zjj on 2023/8/15.
//

import Foundation

/*

@dynamicMemberLookup
public protocol BindingProtocol<T>: CustomStringConvertible, CustomDebugStringConvertible {
    associatedtype T
    func addObserver(target: AnyObject?, observer: @escaping Changed<T>.ObserverHandler)
//    func map<T2>(_ transform: @escaping (T) -> T2) -> any BindingProtocol
    func currentValue() -> T
}

extension BindingProtocol {
    public subscript<Value>(dynamicMember keyPath: KeyPath<T, Value>) -> some BindingProtocol<Value> {
        get {
            return self.map { ele in
                return ele[keyPath: keyPath]
            }
        }
    }

    public func map<T2>(_ transform: @escaping (T) -> T2) -> some BindingProtocol<T2> {
        let bindMap = NewMapBinding<T, T2>(source: self, map: transform)
        return bindMap
    }

    public func join<T2>(_ other: some BindingProtocol<T2>) -> some BindingProtocol<(T, T2)> {
        let bindJoin = NewJoinBinding<T, T2>(self, with: other)
        return bindJoin
    }

    public func join<T2, ResultElement>(_ other: some BindingProtocol<T2>, transform: @escaping (T, T2) -> ResultElement) -> some BindingProtocol<ResultElement> {
        let joinMap = join(other).map(transform)
        return joinMap
    }
}

extension BindingProtocol {
    public var description: String {
        return "\(currentValue())"
    }

    public var debugDescription: String {
        return "\(currentValue())"
    }
}

@dynamicMemberLookup
public struct NewBinding<Element>: BindingProtocol {
    public func addObserver(target: AnyObject?, observer: @escaping Changed<T>.ObserverHandler) {
        guard let wrapper = wrapper else {
            let currentVal = currentValue()
            observer(.init(old: currentVal, new: currentVal))
            return
        }
        wrapper.addObserver(target: target) { changed in
            observer(changed)
        }
    }

    public typealias T = Element

    internal var _currentValueGetter: () -> Element
    public func currentValue() -> Element {
        return _currentValueGetter()
    }

    private weak var wrapper: State<T>?

    public static func constant(value: Element) -> Self {
        return .init(currentValue: value)
    }

    public init(wrapper: State<T>? = nil, currentValue: @escaping @autoclosure () -> Element) {
        self.wrapper = wrapper
        self._currentValueGetter = currentValue
    }
}

private struct NewMapBinding<SourceElement, ResultElement>: BindingProtocol {

    func addObserver(target: AnyObject?, observer: @escaping Changed<ResultElement>.ObserverHandler) {
        source.addObserver(target: target) { changed in
            let changedMap = Changed<ResultElement>(old: mapping(changed.old), new: mapping(changed.new))
            observer(changedMap)
        }
    }

    func currentValue() -> ResultElement {
        return mapping(source.currentValue())
    }

    typealias T = ResultElement
    let source: any BindingProtocol<SourceElement>
    let mapping: (SourceElement) -> ResultElement

    init(source: some BindingProtocol<SourceElement>, map: @escaping (SourceElement) -> ResultElement) {
        self.source = source
        self.mapping = map
    }
}

private struct NewJoinBinding<S1, S2>: BindingProtocol {
    func currentValue() -> (S1, S2) {
        return (source1.currentValue(), source2.currentValue())
    }

    typealias T = (S1, S2)
    var source1: any BindingProtocol<S1>
    var source2: any BindingProtocol<S2>
    init(_ source1: some BindingProtocol<S1>, with source2: some BindingProtocol<S2>) {
        self.source1 = source1
        self.source2 = source2
    }

    public func addObserver(target: AnyObject?, observer: @escaping Changed<(S1, S2)>.ObserverHandler) {
        var c1: Changed<S1>?
        var c2: Changed<S2>?
        let performChanges = {
            if let c1obj = c1, let c2obj = c2 {
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

// MARK: Bool

extension BindingProtocol where T: Equatable {
    public static func == (lhs: Self, rhs: some BindingProtocol<T>) -> some BindingProtocol<Bool> {
        return lhs.join(rhs) { ele, ele2 in
            return ele == ele2
        }
    }

    public static func == (lhs: Self, rhs: T) -> some BindingProtocol<Bool> {
        return lhs.map { ele in
            return ele == rhs
        }
    }

    public static func != (lhs: Self, rhs: some BindingProtocol<T>) -> some BindingProtocol<Bool> {
        return lhs.join(rhs) { ele, ele2 in
            return ele != ele2
        }
    }

    public static func != (lhs: Self, rhs: T) -> some BindingProtocol<Bool> {
        return lhs.map { ele in
            return ele != rhs
        }
    }
}

// MARK: math

extension BindingProtocol where T: BinaryFloatingPoint {
    public static func + (lhs: Self, rhs: T) -> some BindingProtocol<T> {
        return lhs.map { a in
            return a + rhs
        }
    }
    public static func - (lhs: Self, rhs: T) -> some BindingProtocol<T> {
        return lhs.map { a in
            return a - rhs
        }
    }
    public static func * (lhs: Self, rhs: T) -> some BindingProtocol<T> {
        return lhs.map { a in
            return a * rhs
        }
    }
    public static func / (lhs: Self, rhs: T) -> some BindingProtocol<T> {
        return lhs.map { a in
            return a / rhs
        }
    }
    public static func + (lhs: Self, rhs: some BindingProtocol<T>) -> some BindingProtocol<T> {
        return lhs.join(rhs)  { a, b in
            return a + b
        }
    }
    public static func - (lhs: Self, rhs: some BindingProtocol<T>) -> some BindingProtocol<T> {
        return lhs.join(rhs)  { a, b in
            return a - b
        }
    }
    public static func * (lhs: Self, rhs: some BindingProtocol<T>) -> some BindingProtocol<T> {
        return lhs.join(rhs)  { a, b in
            return a * b
        }
    }
    public static func / (lhs: Self, rhs: some BindingProtocol<T>) -> some BindingProtocol<T> {
        return lhs.join(rhs)  { a, b in
            return a / b
        }
    }
}

extension BindingProtocol where T: Comparable {
    public static func < (lhs: Self, rhs: T) -> some BindingProtocol<Bool> {
        return lhs.map { ele in
            return ele < rhs
        }
    }

    public  static func < (lhs: Self, rhs: some BindingProtocol<T>) -> some BindingProtocol<Bool> {
        return lhs.join(rhs) { ele1, ele2 in
            return ele1 < ele2
        }
    }

    public static func > (lhs: Self, rhs: T) -> some BindingProtocol<Bool> {
        return lhs.map { ele in
            return ele > rhs
        }
    }

    public static func > (lhs: Self, rhs: some BindingProtocol<T>) -> some BindingProtocol<Bool> {
        return lhs.join(rhs) { ele1, ele2 in
            return ele1 > ele2
        }
    }
}

*/
