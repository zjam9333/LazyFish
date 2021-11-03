//
//  ZKitViews.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import Foundation
import UIKit

public extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis, distribution: Distribution = .fill, alignment: Alignment = .fill, spacing: CGFloat = 0, @ViewBuilder content: ViewBuilder.ContentBlock) {
        self.init()
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        self.arrangeViews(content)
    }
}

public extension UIView {
    convenience init(_ comment: String = "nothing", @ViewBuilder content: ViewBuilder.ContentBlock) {
        self.init()
        self.arrangeViews(content)
    }
}

public extension UIScrollView {
    internal var zk_scrollViewDelegate: Delegate {
        set {
            let obj = newValue
            objc_setAssociatedObject(self, &Delegate.attributeKey, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let obj = objc_getAssociatedObject(self, &Delegate.attributeKey) as? Delegate {
                return obj
            }
            let newone = Delegate()
            self.zk_scrollViewDelegate = newone
            return newone
        }
    }
    
    internal class Delegate: NSObject, UIScrollViewDelegate {
        static var attributeKey: Int = 0
        var scrollDidScrollHandler: ((CGPoint) -> Void)?
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.scrollDidScrollHandler?(scrollView.contentOffset)
        }
    }
    
    internal class InternalLayoutStackView: UIStackView {
        
        private var actionWhileMoveToSuperview: [(UIView) -> Void] = []
        func appendActionForDidMoveToSuperview(_ action: @escaping (UIView) -> Void) {
            self.actionWhileMoveToSuperview.append(action)
        }
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            if let scr = self.superview as? UIScrollView {
                for i in actionWhileMoveToSuperview {
                    i(scr)
                }
                self.actionWhileMoveToSuperview.removeAll()
            }
        }
    }
    
    convenience init(_ direction: NSLayoutConstraint.Axis = .vertical, spacing: CGFloat = 0, @ViewBuilder content: ViewBuilder.ContentBlock) {
        self.init()
        
        let views = content()
        if direction == .vertical {
            self.showsHorizontalScrollIndicator = false
        } else {
            self.showsVerticalScrollIndicator = false
        }
        self.arrangeViews {
            let stack = InternalLayoutStackView(axis: direction, distribution: .fill, alignment: .fill, spacing: spacing) {
                    views
                }
                .alignment(.allEdges)
            if direction == .vertical {
                _ = stack.frame(filledWidth: true)
            } else {
                _ = stack.frame(filledHeight: true)
            }
            stack
        }
    }
}

// MARK: - 无法重用cellcontent，非常浪费性能，待完善
public typealias TableViewSection = UITableView.Section

public extension UITableView {
    private enum DelegateKey {
        static var attributeKey: Int = 0
    }
    
    internal var zk_tableViewViewDelegate: DataSourceDelegate? {
        set {
            let obj = newValue
            objc_setAssociatedObject(self, &DelegateKey.attributeKey, obj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let obj = objc_getAssociatedObject(self, &DelegateKey.attributeKey) as? DataSourceDelegate {
                return obj
            }
            return nil
        }
    }
    
    // 若干个section
    convenience init(style: Style, @ResultBuilder<TableViewSection> sectionBuilder: ResultBuilder<TableViewSection>.ContentBlock) {
        self.init(frame: .zero, style: style)
        let delegate = DataSourceDelegate()
        self.delegate = delegate
        self.dataSource = delegate
        self.zk_tableViewViewDelegate = delegate
        delegate.sections = sectionBuilder()
        for item in delegate.sections.enumerated() {
            item.element.didUpdate = { [weak self] in
//                self?.reloadSections(IndexSet(integer: i), with: .none)
                self?.reloadData()
            }
        }
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
        
        self.estimatedRowHeight = 44
    }
    
    // 一个动态section
    convenience init<T>(style: Style, binding: Binding<[T]>, @ViewBuilder content: @escaping (T) -> [UIView], action: ((T) -> Void)? = nil) {
        self.init(style: style) {
            Section(binding: binding, cellContent: content, action: action)
        }
    }
    
    // 一个静态section
    convenience init<T>(style: Style, array: [T], @ViewBuilder content: @escaping (T) -> [UIView], action: ((T) -> Void)? = nil) {
        self.init(style: style) {
            Section(array, cellContent: content, action: action)
        }
    }
    
    class Section {
        // MARK: rows
        var rowCount: Int = 0
        var viewsForRow: ((Int) -> [UIView])?
        var didUpdate: (() -> Void)?
        var didClick: ((Int) -> Void)?
        
        public init<T>(_ array: [T], @ViewBuilder cellContent: @escaping ((T) -> [UIView]), action: ((T) -> Void)? = nil) {
            self.resetArray(array, cellContent: cellContent, action: action)
        }
        
        public init<T>(binding: Binding<[T]>, @ViewBuilder cellContent: @escaping ((T) -> [UIView]), action: ((T) -> Void)? = nil) {
            let wrapper = binding.wrapper
            wrapper.addObserver { [weak self, weak wrapper] _ in
                // binding的array发生变化，则更新datasource
                let arr = wrapper?.wrappedValue ?? []
                self?.resetArray(arr, cellContent: cellContent, action: action)
                self?.didUpdate?()
            }
        }
        
        private func resetArray<T>(_ array: [T], @ViewBuilder cellContent: @escaping ((T) -> [UIView]), action: ((T) -> Void)? = nil) {
            self.rowCount = array.count
            self.viewsForRow = { row in
                // TODO: - 这里需要做一个缓存机制！！
                // TODO: - 但是缓存了又如何刷新内部view的内容（文案、图片等）？？
                let obj = array[row]
                return cellContent(obj)
            }
            self.didClick = { row in
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
            self.headerTitleGetter = getter
            return self
        }
        
        public func headerViews(@ViewBuilder getter: @escaping ViewBuilder.ContentBlock) -> Self {
            self.headerViewsGetter = getter
            return self
        }
        
        public func footerTitle(getter: @escaping () -> String?) -> Self {
            self.footerTitleGetter = getter
            return self
        }
        
        public func footerViews(@ViewBuilder getter: @escaping ViewBuilder.ContentBlock) -> Self {
            self.footerViewsGetter = getter
            return self
        }
    }
    
    internal class DataSourceDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
        class WasteSpaceTableViewCell: UITableViewCell {
            func remakeSubviews(_ views: [UIView]) {
                let olds = self.contentView.subviews
                for i in olds {
                    i.removeFromSuperview()
                }
                for i in views {
                    i.removeFromSuperview()
                }
                self.contentView.arrangeViews {
                    views
                }
                // TODO: 反复移除添加必然造成浪费
            }
        }
        
        var sections: [Section] = []
        
        // MARK: ROWS
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return sections.count
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return sections[section].rowCount
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? WasteSpaceTableViewCell ?? WasteSpaceTableViewCell(style: .default, reuseIdentifier: "cell")
            let vi = sections[indexPath.section].viewsForRow?(indexPath.row) ?? []
            cell.remakeSubviews(vi)
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            sections[indexPath.section].didClick?(indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        // MARK: Height
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            if let _ = sections[section].headerTitleGetter {
                return UITableView.automaticDimension
            } else if let _ = sections[section].headerViewsGetter {
                return UITableView.automaticDimension
            }
            return 0
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            if let _ = sections[section].headerTitleGetter {
                return UITableView.automaticDimension
            } else if let _ = sections[section].headerViewsGetter {
                return UITableView.automaticDimension
            }
            return 0
        }
        
        // MARK: Header Footer
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return sections[section].headerTitleGetter?()
        }
        
        func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
            return sections[section].footerTitleGetter?()
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            if let getter = sections[section].headerViewsGetter {
                return UIView {
                    getter()
                }
            }
            return nil
        }
        
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            if let getter = sections[section].footerViewsGetter {
                return UIView {
                    getter()
                }
            }
            return nil
        }
    }
}

