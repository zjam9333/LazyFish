//
//  Animation.swift
//  LazyFishCore
//
//  Created by zjj on 2022/1/10.
//

import Foundation
import UIKit

public enum Animation {
    
}

extension Animation {
    internal struct Options: OptionSet, Hashable {
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public var rawValue: UInt
        
        public typealias RawValue = UInt
        
        // curve
        static let curveEaseInOut = Options(rawValue: 1 << 0)
        static let curveEaseIn = Options(rawValue: 1 << 1)
        static let curveEaseOut = Options(rawValue: 1 << 2)
        static let curveLinear = Options(rawValue: 1 << 3)
        
        // actions
        static let layoutSubviews = Options(rawValue: 1 << 4)
        static let allowUserInteraction = Options(rawValue: 1 << 5)
        static let beginFromCurrentState = Options(rawValue: 1 << 6)
        
        var toUIViewAnimationOptions: UIView.AnimationOptions {
            var options = UIView.AnimationOptions.init(rawValue: 0)
            let map: [Options: UIView.AnimationOptions] = [
                .curveEaseInOut: .curveEaseInOut,
                .curveEaseIn: .curveEaseIn,
                .curveEaseOut: .curveEaseOut,
                .curveLinear: .curveLinear,
                .layoutSubviews: .layoutSubviews,
                .allowUserInteraction: .allowUserInteraction,
                .beginFromCurrentState: .beginFromCurrentState,
            ]
            for i in map {
                if self.contains(i.key) {
                    options.formUnion(i.value)
                }
            }
            return options
        }
    }
    public struct Arguments {
        internal var duration: TimeInterval = 0.25
        internal var delay: TimeInterval = 0
        internal var options: Options = .curveEaseInOut
        
        public static let `default` = Self()
        
        public static func curveEaseInOut(duration: TimeInterval) -> Self {
            var obj = self.default
            obj.duration = duration
            obj.options = .curveEaseInOut
            return obj
        }
        
        public func delay(_ time: TimeInterval) -> Self {
            var newOne = self
            newOne.delay = time
            return newOne
        }
        
        public func speed(_ speed: TimeInterval) -> Self {
            var newOne = self
            if speed != 0 {
                newOne.duration /= speed
            }
            return newOne
        }
    }
}

extension Animation {
    public struct Effects {
        internal var internalTransform: CGAffineTransform = .identity
        
        public static let identity = Self()
        
//        public static func scale(x: CGFloat, y: CGFloat) -> Self {
//            return self//.identity.scale(x: x, y: y)
//        }
//        
//        public static func rotate(r: CGFloat) -> Self {
//            return self//.identity.rotate(r: r)
//        }
//        
//        public static func translate(x: CGFloat, y: CGFloat) -> Self {
//            return self//.identity.translate(x: x, y: y)
//        }
        
        public func scale(x: CGFloat, y: CGFloat) -> Self {
            var newOne = self
            newOne.internalTransform = newOne.internalTransform.scaledBy(x: x, y: y)
            return newOne
        }
        
        public func rotate(r: CGFloat) -> Self {
            var newOne = self
            newOne.internalTransform = newOne.internalTransform.rotated(by: r)
            return newOne
        }
        
        public func translate(x: CGFloat, y: CGFloat) -> Self {
            var newOne = self
            newOne.internalTransform = newOne.internalTransform.translatedBy(x: x, y: y)
            return newOne
        }
    }
}

extension Animation {
    public class Runner {
        internal func performAnimation(option: Animation.Arguments, animation: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: option.duration, delay: option.delay, options: option.options.toUIViewAnimationOptions) {
                animation()
            } completion: { fi in
                completion?(fi)
            }
        }
    }
}

@discardableResult public func ActionWithAnimation(_ option: Animation.Arguments = .default, animation: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) -> Animation.Runner {
    let runner = Animation.Runner()
    runner.performAnimation(option: option, animation: animation, completion: completion)
    return runner
}
