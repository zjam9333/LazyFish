//
//  SwiftUIView.swift
//  LazyFishTest
//
//  Created by zjj on 2022/10/9.
//

import LazyFishCore
import SwiftUI

@available(iOS 13.0, *)
struct Preview: PreviewProvider {
    static var previews: some View {
        SwiftUIViewPresent {
            UILabel("Hello World")
                .textAlignment(.center)
                .alignment(.center)
                .padding(20)
                .backgroundColor(.lightGray)
                .borderColor(.blue)
                .borderWidth(1)
                .cornerRadius(6)
        }
    }
}

@available(iOS 13.0, *)
struct ViewControllerPreview: PreviewProvider {
    static var previews: some View {
        return SwiftUIViewControllerPresent(viewController: UINavigationController(rootViewController: ViewController()))
    }
}
