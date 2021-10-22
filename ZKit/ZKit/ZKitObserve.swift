//
//  ZKitObserve.swift
//  ZKit
//
//  Created by zjj on 2021/10/22.
//

import Foundation

extension ZKit {
    @propertyWrapper class State<T> {
        var wrappedValue: T {
            didSet {
                let newValue = wrappedValue
                let oldValue = oldValue
                for obs in self.observers {
                    let changed = Changed(old: oldValue, new: newValue)
                    obs(changed)
                }
            }
        }
        
        init(wrappedValue: T) {
            self.wrappedValue = wrappedValue
        }
        
        typealias ObserverHandler = (Changed<T>) -> Void
        private var observers = [ObserverHandler]()
        
        func addObserver(observer: @escaping ObserverHandler) {
            self.observers.append(observer)
            let changed = Changed(old: wrappedValue, new: wrappedValue)
            observer(changed)
        }
        
        struct Changed<T> {
            let old: T
            let new: T
        }
        
        var projectedValue: Binding<T> {
            return Binding(wrapper: self)
        }
    }

    struct Binding<T> {
        var wrapper: State<T>
    }
}
