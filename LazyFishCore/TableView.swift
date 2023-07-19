//
//  TableView.swift
//  LazyFishCore
//
//  Created by zjj on 2021/11/25.
//

import UIKit

public extension UITableView {
    
    // 若干个section
    convenience init(style: Style, @ArrayBuilder<Section> sectionBuilder: () -> [Section]) {
        self.init(frame: .zero, style: style)
        self.separatorStyle = .none
        let delegate = DataSourceDelegate()
        self.delegate = delegate
        self.dataSource = delegate
        zk_tableViewViewDelegate = delegate
        delegate.sections = sectionBuilder()
        for (offset, element) in delegate.sections.enumerated() {
            element.didUpdate = { [weak self] in
                UIView.performWithoutAnimation {
                    self?.reloadSections(IndexSet(integer: offset), with: .none)
                }
            }
        }
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        }
        estimatedRowHeight = 44
    }
    
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
    
    internal class LazyFishTableViewCell: UITableViewCell {
        func updateContents(views: [UIView]) {
            for i in contentView.subviews {
                i.removeFromSuperview()
            }
            contentView.arrangeViews {
                views
            }
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
            let cellId = "LazyFishTableViewCell"
            let section = sections[indexPath.section]
            let row = indexPath.row
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? LazyFishTableViewCell ?? LazyFishTableViewCell(style: .default, reuseIdentifier: cellId)
            cell.updateContents(views: section.content?(row) ?? [])
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
            if let _ = sections[section].headerViewsGetter {
                return UITableView.automaticDimension
            }
            return tableView.style == .plain ? 0 : UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            if let _ = sections[section].headerViewsGetter {
                return UITableView.automaticDimension
            }
            return tableView.style == .plain ? 0 : UITableView.automaticDimension
        }
        
        // MARK: Header Footer
        
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


