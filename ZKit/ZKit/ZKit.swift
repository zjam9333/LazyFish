//
//  ZKit.swift
//  ZKit
//
//  Created by zjj on 2021/9/29.
//

import UIKit

enum ZKit {
    class Attribute {
        var padding: [Edges: CGFloat]?
        var offset: CGPoint = .zero
        
        var alignment: Alignment?
        var width: CGFloat?
        var height: CGFloat?
        
        var filledWidth: Bool = false
        var filledHeight: Bool = false
        var onAppear: OnAppearBlock?
    }
    
    typealias OnAppearBlock = (UIView) -> Void
    
    struct Alignment: OptionSet {
        typealias RawValue = Int
        let rawValue: RawValue
        
        static let leading = Alignment(rawValue: 1 << 0)
        static let trailing = Alignment(rawValue: 1 << 1)
        static let top = Alignment(rawValue: 1 << 2)
        static let bottom = Alignment(rawValue: 1 << 3)
        static let allEdges: Alignment = [.leading, .trailing, .top, .bottom]
        
        static let centerX = Alignment(rawValue: 1 << 4)
        static let centerY = Alignment(rawValue: 1 << 5)
        static let center: Alignment = [centerX, centerY]
    }
    
    enum Edges {
        case top, leading, bottom, trailing
    }
    
    enum AssociatedKey {
        static var attributeKey: Int = 0
    }
    
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
    }
}

