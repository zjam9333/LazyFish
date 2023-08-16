//
//  LazyFishObserve.swift
//  LazyFish
//
//  Created by zjj on 2021/10/22.
//

import Foundation
import UIKit

public typealias Binding = OldBinding

public struct Changed<T> {
    internal typealias ValueGetter = () -> T
    public var old: T {
        _oldGetter()
    }
    public var new: T {
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
        if let observable = wrappedValue as? StateObject {
            observable.prepareAllPublished(observer: self)
        }
    }
    private var observers = [ObserverTargetAction]()
    
    public var projectedValue: Binding<T> {
        Binding(wrapper: self, currentValue: self.currentValue())
    }
    
    internal func currentValue() -> T {
        return wrappedValue
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
    
    func addObserver(target: AnyObject?, observer: @escaping Changed<T>.ObserverHandler) {
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

protocol StateProtocol: AnyObject {
    func sendPropertyChanged()
}

extension State: StateProtocol {
    func sendPropertyChanged() {
        let old = wrappedValue
        wrappedValue = old
    }
}
