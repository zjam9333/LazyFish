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
            for obs in self.observers {
                let changed = Changed(old: oldValue, new: newValue)
                obs(changed)
            }
        }
    }
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    public typealias ObserverHandler = (Changed<T>) -> Void
    private var observers = [ObserverHandler]()
    public func addObserver(observer: @escaping ObserverHandler) {
        self.observers.append(observer)
        let changed = Changed(old: wrappedValue, new: wrappedValue)
        observer(changed)
    }
    public struct Changed<T> {
        let old: T
        let new: T
    }
    
    public var projectedValue: Binding<T> {
        return Binding(wrapper: self)
    }
}

public struct Binding<T> {
    var wrapper: State<T>
}
