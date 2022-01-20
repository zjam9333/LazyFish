//
//  GeometryReader.swift
//  LazyFishCore
//
//  Created by zjj on 2022/1/18.
//

import Foundation
import UIKit

public struct GeometryProxy {
    public var size: CGSize = .zero
}

public func GeometryReader(@ViewBuilder contentBuilder: (Binding<GeometryProxy>) -> [UIView]) -> UIView {
    let obj = GeometryReaderView(contentBuilder: contentBuilder)
    return obj
}

internal class GeometryReaderView: TouchIgnoreContainerView {
    var userCreatedContents: [UIView] = []
    
    override var viewsAcceptedTouches: [UIView] {
        return userCreatedContents
    }
    
    @State var proxy = GeometryProxy()
    
    override var bounds: CGRect {
        set {
            super.bounds = newValue
            DispatchQueue.main.async {
                self.proxy.size = newValue.size
            }
        }
        get {
            super.bounds
        }
    }
    
    convenience init(@ViewBuilder contentBuilder: (Binding<GeometryProxy>) -> [UIView]) {
        self.init()
        let contents = contentBuilder(self.$proxy)
        userCreatedContents = contents
        arrangeViews {
            contents
        }
    }
}
