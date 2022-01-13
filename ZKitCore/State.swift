//
//  ZKitObserve.swift
//  ZKit
//
//  Created by zjj on 2021/10/22.
//

import Foundation

public struct Changed<T> {
    internal typealias ValueGetter = () -> T
    var old: T {
        _oldGetter()
    }
    var new: T {
        _newGetter()
    }
    let _oldGetter: ValueGetter
    let _newGetter: ValueGetter
    init(old: @escaping @autoclosure ValueGetter, new: @escaping @autoclosure ValueGetter) {
        _oldGetter = old
        _newGetter = new
    }
    public typealias ObserverHandler = (Changed) -> Void
}

@propertyWrapper public class State<T> {
    public var wrappedValue: T {
        didSet {
            sendChanged(oldValue)
        }
    }
    
    fileprivate func sendChanged(_ old: T?) {
        let val = wrappedValue
        let oldVal = old ?? val
        let changed = Changed(old: oldVal, new: val)
        callAllObservers(changed: changed)
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    private var observers = [ObserverTargetAction]()
    
    public lazy var projectedValue: Binding<T> = Binding(wrapper: self) // 这样可以强饮用第一个binding
    // {
//        return Binding(wrapper: self)
//    }
}

extension State {
    
    private class ObserverTargetAction {
        weak var target: AnyObject?
        var action: Changed<T>.ObserverHandler
        init(target: AnyObject, action: @escaping Changed<T>.ObserverHandler) {
            self.target = target
            self.action = action
        }
    }
    
    fileprivate func addObserver(target: AnyObject?, observer: @escaping Changed<T>.ObserverHandler) {
        removeAnyExpiredObservers()
        guard let target = target else {
            return
        }
        observers.append(.init(target: target, action: observer))
        let val = wrappedValue
        let changed = Changed(old: val, new: val)
        observer(changed)
    }
    
    private func callAllObservers(changed: Changed<T>) {
        // filter && call
        observers = observers.filter { tarObj in
            if tarObj.target == nil {
                return false
            }
            tarObj.action(changed)
            return true
        }
    }
    
    private func removeAnyExpiredObservers() {
        // filter
        observers = observers.filter { tarObj in
            if tarObj.target == nil {
                return false
            }
            return true
        }
    }
}

public class Binding<Element> {

    private weak var wrapper: State<Element>?
    
    init(wrapper: State<Element>?) {
        self.wrapper = wrapper
    }
    
    deinit {
        print("deinit", self)
    }
    
    public func addObserver(target: AnyObject?, observer: @escaping Changed<Element>.ObserverHandler) {
        wrapper?.addObserver(target: target) { changed in
            observer(changed)
        }
    }
    
    public func map<ResultElement>(_ transform: @escaping (Element) -> ResultElement) -> Binding<ResultElement> {
        let bindMap = MapBinding<Element, ResultElement>(source: self, map: transform)
        return bindMap
    }
    
    public func join<OtherElement>(_ other: Binding<OtherElement>) -> Binding<(Element, OtherElement)> {
        let bindJoin = JoinBinding<Element, OtherElement>(self, with: other)
        return bindJoin
    }
    
    public func join<OtherElement, ResultElement>(_ other: Binding<OtherElement>, transform: @escaping (Element, OtherElement) -> ResultElement) -> Binding<ResultElement> {
        let joinMap = join(other).map(transform)
        return joinMap
    }
    
    public func zip<OtherElement, ResultElement>(_ other: Binding<OtherElement>, transform: @escaping (Element, OtherElement) -> ResultElement) -> Binding<ResultElement> {
        let joinMap = ZipBinding<Element, OtherElement>(self, with: other).map(transform)
        return joinMap
    }
}

private class MapBinding<SourceElement, ResultElement>: Binding<ResultElement> {
    var source: Binding<SourceElement>
    var map: (SourceElement) -> ResultElement
    init(source: Binding<SourceElement>, map: @escaping (SourceElement) -> ResultElement) {
        self.source = source
        self.map = map
        super.init(wrapper: nil)
    }
    
    public override func addObserver(target: AnyObject?, observer: @escaping Changed<ResultElement>.ObserverHandler) {
        let map = self.map
        source.addObserver(target: target) { changed in
            let changedMap = Changed<ResultElement>(old: map(changed.old), new: map(changed.new))
            observer(changedMap)
        }
    }
}

private class JoinBinding<S1, S2>: Binding<(S1, S2)> {
    var source1: Binding<S1>
    var source2: Binding<S2>
    init(_ source1: Binding<S1>, with source2: Binding<S2>) {
        self.source1 = source1
        self.source2 = source2
        super.init(wrapper: nil)
    }
    
    public override func addObserver(target: AnyObject?, observer: @escaping Changed<(S1, S2)>.ObserverHandler) {
        var c1: Changed<S1>?
        var c2: Changed<S2>?
        let shouldClean = (self as? ZipBinding<S1, S2>) != nil
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
private class ZipBinding<S1, S2>: JoinBinding<S1, S2> {
}
