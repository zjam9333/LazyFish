//
//  CollectionView.swift
//  ZKitCore
//
//  Created by zjj on 2021/11/25.
//

import UIKit


public extension UICollectionView {
    
    // 若干个section
    convenience init(@ArrayBuilder<Section> sectionBuilder: ArrayBuilder<Section>.ContentBlock) {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        self.init(frame: .zero, collectionViewLayout: layout)
        bounces = true
        alwaysBounceVertical = true
        let delegate = DataSourceDelegate(collectionView: self)
        self.delegate = delegate
        self.dataSource = delegate
        zk_collectionViewViewDelegate = delegate
        delegate.sections = sectionBuilder()
        for (offset, element) in delegate.sections.enumerated() {
            element.didUpdate = { [weak self] in
                UIView.performWithoutAnimation {
                    self?.reloadSections(IndexSet(integer: offset))
                }
            }
        }
    }
    
    // 一个动态section
    convenience init<T>(binding: Binding<[T]>?, @ViewBuilder content: @escaping (T) -> [UIView], action: ((T) -> Void)? = nil) {
        self.init {
            Section(binding: binding, cellContent: content, action: action)
        }
    }
    
    // 一个静态section
    convenience init<T>(array: [T], @ViewBuilder content: @escaping (T) -> [UIView], action: ((T) -> Void)? = nil) {
        self.init {
            Section(array, cellContent: content, action: action)
        }
    }
}

extension UICollectionView {
    
    private enum DelegateKey {
        static var attributeKey: Int = 0
    }
    
    private var zk_collectionViewViewDelegate: DataSourceDelegate? {
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
    
    class WasteSpaceCollectionViewCell: UICollectionViewCell {
        func remakeSubviews(_ views: [UIView]) {
            let olds = contentView.subviews
            for i in olds {
                i.removeFromSuperview()
            }
            for i in views {
                i.removeFromSuperview()
            }
            contentView.arrangeViews {
                views
            }
            // TODO: 反复移除添加必然造成浪费
            // 不确定view层级的变化对autolayout的影响有多大
        }
    }
    
    private class DataSourceDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        let collectionView: UICollectionView
        init(collectionView: UICollectionView) {
            self.collectionView = collectionView
            collectionView.register(WasteSpaceCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
            super.init()
        }
        
        var sections: [Section] = []
        
        // MARK: ROWS
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return sections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return sections[section].rowCount
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? WasteSpaceCollectionViewCell ?? WasteSpaceCollectionViewCell()
            let vi = sections[indexPath.section].viewsForRow?(indexPath.row) ?? []
            cell.remakeSubviews(vi)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            sections[indexPath.section].didClick?(indexPath.row)
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            let showingRows = collectionView.indexPathsForVisibleItems.map { indexpath in
                indexpath.row
            }
            let section = sections[indexPath.section]
            section.removeCacheIfNeed(withShowingRows: showingRows)
        }
        
        /*
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
         */
    }
}
