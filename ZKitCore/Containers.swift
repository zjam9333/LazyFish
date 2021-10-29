//
//  Containers.swift
//  ZKitCore
//
//  Created by zjj on 2021/10/29.
//

import Foundation
import UIKit

internal class ObserveContainer: UIView {
    
    func observeContentProperties(_ content: UIView) {
        self.resetContentKeyPathObservations {
            self.observe(obj: content, keyPath: \.isHidden)
        }
    }
    
    private var observeTokens = [NSKeyValueObservation]()
    private typealias KVOResultBuilder = ResultBuilder<NSKeyValueObservation>
    
    private func resetContentKeyPathObservations(@KVOResultBuilder _ content: KVOResultBuilder.ContentBlock) {
        self.observeTokens.removeAll()
        let kvo = content()
        observeTokens.append(contentsOf: kvo)
    }
    
    private func observe<T: UIView, Value>(obj: T, keyPath: WritableKeyPath<T, Value>) -> NSKeyValueObservation {
        let obs = obj.observe(keyPath, options: .new) { [weak self] view, change in
            if let newValue = change.newValue, var myself = self as? T {
                myself[keyPath: keyPath] = newValue
            }
        }
        return obs
    }
}

internal class PaddingContainerView: ObserveContainer {
    func addContentView(_ content: UIView, padding: [Edge: CGFloat], offset: CGPoint = .zero) {
        self.addSubview(content)
        self.observeContentProperties(content)
        
        content.translatesAutoresizingMaskIntoConstraints = false
        
        let offset: CGPoint = offset
        let top = offset.y + (padding[.top] ?? 0)
        let bottom = offset.y - (padding[.bottom] ?? 0)
        let leading = offset.x + (padding[.leading] ?? 0)
        let trailing = offset.x - (padding[.trailing] ?? 0)
        
        content.topAnchor.constraint(equalTo: self.topAnchor, constant: top).isActive = true
        content.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom).isActive = true
        content.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading).isActive = true
        content.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailing).isActive = true
    }
    
}

internal class ForEachCellContainer: ObserveContainer {
//    override func arrangeViews(ignoreAlignments: Bool = false, _ content: () -> [UIView]) -> Self {
//        return super.arrangeViews(ignoreAlignments: ignoreAlignments, content)
//    }
}
