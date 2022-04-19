//
//  TableView.swift
//  LazyFishCore
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
        zk_tableViewViewDelegate = delegate
        delegate.sections = sectionBuilder()
        for (offset, element) in delegate.sections.enumerated() {
            element.didUpdate = { [weak self] in
                UIView.performWithoutAnimation {
                    self?.reloadSections(IndexSet(integer: offset), with: .none)
                }
            }
        }
//        if #available(iOS 15.0, *) {
//            sectionHeaderTopPadding = 0
//        }
        
        estimatedRowHeight = 44
    }
    
    // 一个动态section
    convenience init<T>(style: Style, binding: Binding<[T]>?, @ViewBuilder content: @escaping (Binding<T>) -> [UIView], action: ((T) -> Void)? = nil) {
        self.init(style: style) {
            Section(binding: binding, cellContent: content, action: action)
        }
    }
    
    // 一个静态section
    convenience init<T>(style: Style, array: [T], @ViewBuilder content: @escaping (Binding<T>) -> [UIView], action: ((T) -> Void)? = nil) {
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
    
    internal class LazyFishTableViewCell: UITableViewCell {
        @State var model: Any
        
        init(model: Any, reuseIdentifier: String?, viewContent: (Binding<Any>) -> [UIView]) {
            self._model = State<Any>.init(wrappedValue: model)
            super.init(style: .default, reuseIdentifier: reuseIdentifier)
            self.contentView.arrangeViews {
                viewContent($model)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
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
            let cellId = "section:\(indexPath.section)"
            let section = sections[indexPath.section]
            let model = section.array[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? LazyFishTableViewCell ?? LazyFishTableViewCell(model: model, reuseIdentifier: cellId, viewContent: { anyBinding in
                return section.content?(anyBinding) ?? []
            })
            cell.model = model
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
    }
}


