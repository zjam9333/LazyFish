//
//  SwiftUIViewControllerPresent.swift
//  LazyFishTest
//
//  Created by zjj on 2023/7/10.
//

import Foundation
import LazyFishCore
import SwiftUI

@available(iOS 13.0, *)
struct ViewControllerPreview: PreviewProvider {
    static var previews: some View {
        return SwiftUIViewControllerPresent(viewController: UINavigationController(rootViewController: ViewController()))
    }
}
