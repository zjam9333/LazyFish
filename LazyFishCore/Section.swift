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
            return lhs.anyHashable == rhs.anyHashable && lhs.offset == rhs.offset
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(anyHashable)
            hasher.combine(offset)
        }
        
        let anyHashable: AnyHashable
        let offset: AnyHashable
        
        var didClick: () -> Void
        var content: () -> [UIView]
    }
    
    public init(@ArrayBuilder<SectionCellContent> content: () -> [SectionCellContent]) {
        let contents = content()
        items = contents.map { ele in
            return Item(anyHashable: UUID(), offset: self.id) {
                ele.action()
            } content: {
                ele.contents()
            }
        }
    }
    
    public init<S: RandomAccessCollection>(_ array: S, @ViewBuilder cellContent: @escaping (S.Element) -> [UIView], action: ((S.Element) -> Void)? = nil) where S.Element: Hashable {
        resetArray(array, cellContent: cellContent, action: action)
    }
    
    public init<S: RandomAccessCollection>(binding: Binding<S>?, @ViewBuilder cellContent: @escaping (S.Element) -> [UIView], action: ((S.Element) -> Void)? = nil) where S.Element: Hashable {
        binding?.addObserver(target: self) { [weak self] changed in
            // binding的array发生变化，则更新datasource
            let arr = changed.new
            self?.resetArray(arr, cellContent: cellContent, action: action)
            self?.didUpdate?()
        }
    }
    
    private func resetArray<S: RandomAccessCollection>(_ array: S, @ViewBuilder cellContent: @escaping (S.Element) -> [UIView], action: ((S.Element) -> Void)? = nil) where S.Element: Hashable {
        items = array.map { ele in
            return Item(anyHashable: ele, offset: self.id) {
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
