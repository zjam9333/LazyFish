//
//  Preview.swift
//  LazyFishCore
//
//  Created by zjj on 2022/10/9.
//

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, *)
public struct SwiftUIViewPresent: UIViewRepresentable {
    let views: [UIView]
    
    public init(@ViewBuilder content: ViewBuilder.ContentBlock) {
        views = content()
    }
    
    public func makeUIView(context: Context) -> UIView {
        return UIView {
            views
        }
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

@available(iOS 13.0, *)
public struct SwiftUIViewControllerPresent: UIViewControllerRepresentable {
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    let viewController: UIViewController
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        return viewController
    }
}

#endif
