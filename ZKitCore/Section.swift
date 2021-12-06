//
//  Section.swift
//  ZKitCore
//
//  Created by zjj on 2021/11/25.
//

import UIKit

// MARK: - 无法重用cellcontent，非常浪费性能，待完善
public class Section {
    // MARK: rows
    var rowCount: Int = 0
    var viewsForRow: ((Int) -> [UIView])?
    var didUpdate: (() -> Void)?
    var didClick: ((Int) -> Void)?
    
    public init<T>(_ array: [T], @ViewBuilder cellContent: @escaping ((T) -> [UIView]), action: ((T) -> Void)? = nil) {
        resetArray(array, cellContent: cellContent, action: action)
    }
    
    public init<T>(binding: Binding<[T]>?, @ViewBuilder cellContent: @escaping ((T) -> [UIView]), action: ((T) -> Void)? = nil) {
        let wrapper = binding?.wrapper
        wrapper?.addObserver(target: self) { [weak self] changed in
            // binding的array发生变化，则更新datasource
            let arr = changed.new
            self?.resetArray(arr, cellContent: cellContent, action: action)
            self?.didUpdate?()
        }
    }
    
    // MARK: Cache
    private struct Cache {
        let cellContents: [UIView]
    }
    private var cellCaches = [Int: Cache]()
    
    private func resetArray<T>(_ array: [T], @ViewBuilder cellContent: @escaping ((T) -> [UIView]), action: ((T) -> Void)? = nil) {
        cellCaches.removeAll()
        rowCount = array.count
        viewsForRow = { [weak self] row in
            // TODO: - 这里需要做一个缓存机制！！
            // TODO: - 但是缓存了又如何刷新内部view的内容（文案、图片等）？？
            // 直接重新创建subviews，简单粗暴，浪费时间
//                let obj = array[row]
//                return cellContent(obj)
            
            // MARK: 能否假设： 在reloadData之前，同一个indexPath的cell总是相同？即使滑上滑下
            // 创建过的subviews缓存起来，浪费空间
            guard let cacheContents = self?.cellCaches[row]?.cellContents else {
                let obj = array[row]
                let newContents = cellContent(obj)
                self?.cellCaches[row] = Cache(cellContents: newContents)
                return newContents
                // 这里的缓存随着滑动，会堆积
            }
            return cacheContents
        }
        didClick = { row in
            let obj = array[row]
            action?(obj)
        }
    }
    
    func removeCacheIfNeed(withShowingRows: [Int]) {
        guard let maxValue = withShowingRows.max(), let minValue = withShowingRows.min() else {
            return
        }
        // 缓存中，超出屏幕的view移除
        let threshold = 10
        let allKeyToRemove = cellCaches.keys.filter { i in
            return i < minValue - threshold || i > maxValue + threshold
        }
        for i in allKeyToRemove {
            cellCaches[i] = nil
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
