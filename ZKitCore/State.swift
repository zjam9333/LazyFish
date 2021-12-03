//
//  ZKitObserve.swift
//  ZKit
//
//  Created by zjj on 2021/10/22.
//

import Foundation

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

public struct Binding<T> {
    var wrapper: State<T>
}

extension State {
    public typealias ObserverHandler = (Changed<T>) -> Void
    public struct Changed<T> {
        let old: T
        let new: T
    }
    
    private class ObserverTargetAction {
        weak var target: AnyObject?
        var action: ObserverHandler
        init(target: AnyObject, action: @escaping ObserverHandler) {
            self.target = target
            self.action = action
        }
    }
    
    public func addObserver(observer: @escaping ObserverHandler) {
        addObserver(target: self, observer: observer)
    }
    
    public func addObserver(target: AnyObject?, observer: @escaping ObserverHandler) {
        removeAnyExpiredObservers()
        guard let target = target else {
            return
        }
        observers.append(.init(target: target, action: observer))
        let changed = Changed(old: wrappedValue, new: wrappedValue)
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
