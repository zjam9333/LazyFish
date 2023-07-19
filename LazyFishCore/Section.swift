//
//  Section.swift
//  LazyFishCore
//
//  Created by zjj on 2021/11/25.
//

import UIKit

public struct SectionCellContent {
    let contents: () -> [UIView]
    let action: () -> Void
    public init(@ViewBuilder contents: @escaping (() -> [UIView]), action: @escaping () -> Void) {
        self.action = action
        self.contents = contents
    }
}

public class Section {
    
    var rowCount: Int = 0
    var didUpdate: (() -> Void)?
    var didClick: ((Int) -> Void)?
    var content: ((Int) -> [UIView])?
    
    public init(@ArrayBuilder<SectionCellContent> content: () -> [SectionCellContent]) {
        let contents = content()
        self.rowCount = contents.count
        self.content = { index in
            return contents[index].contents()
        }
        self.didClick = { index in
            contents[index].action()
        }
    }
    
    public init<T>(_ array: [T], @ViewBuilder cellContent: @escaping (T) -> [UIView], action: ((T) -> Void)? = nil) {
        resetArray(array, cellContent: cellContent, action: action)
    }
    
    public init<T>(binding: Binding<[T]>?, @ViewBuilder cellContent: @escaping (T) -> [UIView], action: ((T) -> Void)? = nil) {
        binding?.addObserver(target: self) { [weak self] changed in
            // binding的array发生变化，则更新datasource
            let arr = changed.new
            self?.resetArray(arr, cellContent: cellContent, action: action)
            self?.didUpdate?()
        }
    }
    
    private func resetArray<T>(_ array: [T], @ViewBuilder cellContent: @escaping (T) -> [UIView], action: ((T) -> Void)? = nil) {
        content = { index in
            return cellContent(array[index])
        }
        rowCount = array.count
        didClick = { row in
            let obj = array[row]
            action?(obj)
        }
    }
    
    // MARK: header footer
    var headerViewsGetter: ((() -> [UIView]))?
    var footerViewsGetter: ((() -> [UIView]))?
    
    public func headerViews(@ViewBuilder getter: @escaping (() -> [UIView])) -> Self {
        headerViewsGetter = getter
        return self
    }
    
    public func footerViews(@ViewBuilder getter: @escaping (() -> [UIView])) -> Self {
        footerViewsGetter = getter
        return self
    }

    // MARK: contentInset
    var contentInset: UIEdgeInsets = .zero
    public func contentInset(getter: () -> UIEdgeInsets) -> Self {
        contentInset = getter()
        return self
    }
}
