//
//  TableView.swift
//  ZKitCore
//
//  Created by zjj on 2021/11/25.
//

import UIKit

public extension UITableView {
    
    // 若干个section
    convenience init(style: Style, @ArrayBuilder<Section> sectionBuilder: ArrayBuilder<Section>.ContentBlock) {
        self.init(frame: .zero, style: style)
        let delegate = DataSourceDelegate()
        self.delegate = delegate
        self.dataSource = delegate
        self.zk_tableViewViewDelegate = delegate
        delegate.sections = sectionBuilder()
        for (offset, element) in delegate.sections.enumerated() {
            element.didUpdate = { [weak self] in
                UIView.performWithoutAnimation {
                    self?.reloadSections(IndexSet(integer: offset), with: .none)
                }
            }
        }
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
        
        self.estimatedRowHeight = 44
    }
    
    // 一个动态section
    convenience init<T>(style: Style, binding: Binding<[T]>?, @ViewBuilder content: @escaping (T) -> [UIView], action: ((T) -> Void)? = nil) {
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
}

extension UITableView {
    
    private enum DelegateKey {
        static var attributeKey: Int = 0
    }
    
    private var zk_tableViewViewDelegate: DataSourceDelegate? {
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
    
    private class WasteSpaceTableViewCell: UITableViewCell {
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
            // 不确定view层级的变化对autolayout的影响有多大
        }
    }
    
    private class DataSourceDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
        
        
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
            return tableView.style == .plain ? 0 : UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            if let _ = sections[section].headerTitleGetter {
                return UITableView.automaticDimension
            } else if let _ = sections[section].headerViewsGetter {
                return UITableView.automaticDimension
            }
            return tableView.style == .plain ? 0 : UITableView.automaticDimension
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
        
        // MARK: Cell rolling
        
        func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let showingRows = tableView.indexPathsForVisibleRows?.map { indexpath in
                indexpath.row
            } ?? []
            let section = sections[indexPath.section]
            section.removeCacheIfNeed(withShowingRows: showingRows)
        }
        
    }
}


