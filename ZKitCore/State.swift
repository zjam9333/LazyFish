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
            let newValue = wrappedValue
            let oldValue = oldValue
            let changed = Changed(old: oldValue, new: newValue)
            callAllObservers(changed: changed)
        }
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    private var observers = [ObserverTargetAction]()
    
    public var projectedValue: Binding<T> {
        return Binding(wrapper: self)
    }
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
    
    func assignValue(_ value: Element) {
        wrapper?.wrappedValue = value
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
