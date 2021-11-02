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
    
    convenience init(style: Style, @ResultBuilder<TableViewSection> content: ResultBuilder<TableViewSection>.ContentBlock) {
        self.init(frame: .zero, style: style)
        let delegate = DataSourceDelegate()
        self.delegate = delegate
        self.dataSource = delegate
        self.zk_tableViewViewDelegate = delegate
        delegate.sections = content()
        for item in delegate.sections.enumerated() {
            item.element.didUpdate = { [weak self] in
//                self?.reloadSections(IndexSet(integer: i), with: .none)
                self?.reloadData()
            }
        }
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 44
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    class Section {
        var rowCount: Int = 0
        var viewsForRow: ((Int) -> [UIView])?
        var didUpdate: (() -> Void)?
        var didClick: ((Int) -> Void)?
        
        public init<T>(_ binding: Binding<Array<T>>, @ViewBuilder cellContent: @escaping ((T) -> [UIView]), action: ((T) -> Void)? = nil) {
            let wrapper = binding.wrapper
            wrapper.addObserver { [weak self, weak wrapper] _ in
                let count = wrapper?.wrappedValue.count ?? 0
                self?.rowCount = count
                self?.viewsForRow = { row in
                    // TODO: - 这里需要做一个缓存机制！！
                    // TODO: - 但是缓存了又如何刷新内容？？
                    if let obj = wrapper?.wrappedValue[row] {
                        return cellContent(obj)
                    }
                    return []
                }
                self?.didClick = { row in
                    if let obj = wrapper?.wrappedValue[row] {
                        action?(obj)
                    }
                }
                self?.didUpdate?()
            }
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
            }
        }
        
        var sections: [Section] = []
        
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
        }
    }
}

