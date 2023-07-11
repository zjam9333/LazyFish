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
    public struct Arguments {
        internal var duration: TimeInterval = 0.25
        internal var delay: TimeInterval = 0
        internal var options: UIView.AnimationOptions = []
        
        public static let `default` = Self()
        
        public static func curveEaseInOut(duration: TimeInterval) -> Self {
            var obj = Self()
            obj.duration = duration
            obj.options = .curveEaseInOut
            return obj
        }
        
        public static func curveLinear(duration: TimeInterval) -> Self {
            var obj = Self()
            obj.duration = duration
            obj.options = .curveLinear
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
            UIView.animate(withDuration: option.duration, delay: option.delay, options: option.options) {
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
