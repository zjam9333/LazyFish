//
//  StateObject.swift
//  LazyFishCore
//
//  Created by zjj on 2023/8/14.
//

import Foundation

protocol StateObjectPropertyProtocol {
    func addObserver<T: StateProtocol>(observer: T)
}

@propertyWrapper public class StateProperty<T>: StateObjectPropertyProtocol {
    public var wrappedValue: T {
        didSet {
            if let observer = someState as? StateProtocol {
                observer.sendPropertyChanged()
            }
        }
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    func addObserver<T2: StateProtocol>(observer: T2) {
        //        print("addObserver", observer)
        self.someState = observer
    }
    
    weak var someState: AnyObject?
}

public protocol StateObject: AnyObject {
    
}

extension StateObject {
    func prepareAllPublished<T: StateProtocol>(observer: T) {
        let mirr = Mirror(reflecting: self)
        for i in mirr.children {
            if let c = i.value as? StateObjectPropertyProtocol {
                c.addObserver(observer: observer)
            }
        }
    }
}
