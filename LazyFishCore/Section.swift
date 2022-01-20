//
//  Section.swift
//  LazyFishCore
//
//  Created by zjj on 2021/11/25.
//

import UIKit

public class Section {
    
    var rowCount: Int = 0
    var didUpdate: (() -> Void)?
    var didClick: ((Int) -> Void)?
    var array: [Any] = []
    var content: ((Binding<Any>) -> [UIView])?
    
    public init<T>(_ array: [T], @ViewBuilder cellContent: @escaping (Binding<T>) -> [UIView], action: ((T) -> Void)? = nil) {
        resetArray(array, cellContent: cellContent, action: action)
    }
    
    public init<T>(binding: Binding<[T]>?, @ViewBuilder cellContent: @escaping (Binding<T>) -> [UIView], action: ((T) -> Void)? = nil) {
        binding?.addObserver(target: self) { [weak self] changed in
            // binding的array发生变化，则更新datasource
            let arr = changed.new
            self?.resetArray(arr, cellContent: cellContent, action: action)
            self?.didUpdate?()
        }
    }
    
    private func resetArray<T>(_ array: [T], @ViewBuilder cellContent: @escaping (Binding<T>) -> [UIView], action: ((T) -> Void)? = nil) {
        self.array = array
        content = { anyBinding in
            let toBingdintT = anyBinding.map { an in
                return an as! T // TODO: - 不安全
            }
            return cellContent(toBingdintT)
        }
        rowCount = array.count
        didClick = { row in
            let obj = array[row]
            action?(obj)
        }
    }
    
    // MARK: header footer
    var headerTitleGetter: (() -> String?)?
    var headerViewsGetter: (ViewBuilder.ContentBlock)?
    var footerTitleGetter: (() -> String?)?
    var footerViewsGetter: (ViewBuilder.ContentBlock)?
    
    public func headerTitle(getter: @escaping () -> String?) -> Self {
        headerTitleGetter = getter
        return self
    }
    
    public func headerViews(@ViewBuilder getter: @escaping ViewBuilder.ContentBlock) -> Self {
        headerViewsGetter = getter
        return self
    }
    
    public func footerTitle(getter: @escaping () -> String?) -> Self {
        footerTitleGetter = getter
        return self
    }
    
    public func footerViews(@ViewBuilder getter: @escaping ViewBuilder.ContentBlock) -> Self {
        footerViewsGetter = getter
        return self
    }
}
