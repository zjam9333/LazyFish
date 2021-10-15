//
//  ZKit.swift
//  ZKit
//
//  Created by zjj on 2021/9/29.
//

import UIKit

enum ZKit {
    class Attribute {
        var margin: [Edges: CGFloat]?
        
        var alignment: Alignment?
        var width: CGFloat?
        var height: CGFloat?
        
        var filledWidth: Bool = false
        var filledHeight: Bool = false
    }
    
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
        static var onAppearKey: Int = 0
        static var onDisappearKey: Int = 0
    }
    
    class PaddingContainerView: UIView {
        private enum KeyPath: String {
            case hidden
        }
        private weak var contentView: UIView? = nil
        
        func addContentView(_ content: UIView, padding: [Edges: CGFloat]) {
            self.addSubview(content)
            self.contentView = content
            
            content.translatesAutoresizingMaskIntoConstraints = false
            content.topAnchor.constraint(equalTo: self.topAnchor, constant: padding[.top] ?? 0).isActive = true
            content.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(padding[.bottom] ?? 0)).isActive = true
            content.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding[.leading] ?? 0).isActive = true
            content.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(padding[.trailing] ?? 0)).isActive = true
            
            content.addObserver(self, forKeyPath: KeyPath.hidden.rawValue, options: .new, context: nil)
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if (object as? UIView) == self.contentView {
                let newVal = change?[.newKey]
                if keyPath == KeyPath.hidden.rawValue {
                    if let isHidden = newVal as? Bool {
                        self.isHidden = isHidden
                    }
                }
            }
        }
    }
}

