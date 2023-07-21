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

public class Section: Hashable {
    public static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var rowCount: Int {
        return items.count
    }
    var didUpdate: (() -> Void)?
    var items: [Item] = []
    
    struct Item: Hashable {
        static func == (lhs: Item, rhs: Item) -> Bool {
            return lhs.anyHashable == rhs.anyHashable
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(anyHashable)
        }
        
        let anyHashable: AnyHashable
        
        var didClick: () -> Void
        var content: () -> [UIView]
    }
    
    public init(@ArrayBuilder<SectionCellContent> content: () -> [SectionCellContent]) {
        let contents = content()
        items = contents.map { ele in
            return Item(anyHashable: UUID()) {
                ele.action()
            } content: {
                ele.contents()
            }
        }
    }
    
    public init<T: Hashable>(_ array: [T], @ViewBuilder cellContent: @escaping (T) -> [UIView], action: ((T) -> Void)? = nil) {
        resetArray(array, cellContent: cellContent, action: action)
    }
    
    public init<T: Hashable>(binding: Binding<[T]>?, @ViewBuilder cellContent: @escaping (T) -> [UIView], action: ((T) -> Void)? = nil) {
        binding?.addObserver(target: self) { [weak self] changed in
            // binding的array发生变化，则更新datasource
            let arr = changed.new
            self?.resetArray(arr, cellContent: cellContent, action: action)
            self?.didUpdate?()
        }
    }
    
    private func resetArray<T: Hashable>(_ array: [T], @ViewBuilder cellContent: @escaping (T) -> [UIView], action: ((T) -> Void)? = nil) {
        items = array.map { ele in
            return Item(anyHashable: ele) {
                action?(ele)
            } content: {
                cellContent(ele)
            }
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
