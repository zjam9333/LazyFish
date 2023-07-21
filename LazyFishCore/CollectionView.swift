//
//  CollectionView.swift
//  LazyFishCore
//
//  Created by zjj on 2023/7/12.
//

import UIKit

public extension UICollectionView {
    
    // 若干个section
    convenience init(@ArrayBuilder<Section> sectionBuilder: () -> [Section]) {
        let flowLayout = SLCollectionViewGridLayout()
        // 设置sectionHeadersPinToVisibleBounds有bug
//        flowLayout.sectionHeadersPinToVisibleBounds = true
//        flowLayout.sectionFootersPinToVisibleBounds = true
        flowLayout.estimatedItemSize = CGSize(width: 40, height: 40)
        self.init(frame: .zero, collectionViewLayout: flowLayout)
        self.alwaysBounceVertical = true
        let sections = sectionBuilder()
        let delegate = DataSourceDelegate(sections: sections, collectionView: self)
        self.delegate = delegate
        zk_collectionViewViewDelegate = delegate
    }
    
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
    
    internal class LazyFishCollectionViewCell: UICollectionViewCell {
        func updateContents(views: [UIView]) {
            for i in contentView.subviews {
                i.removeFromSuperview()
            }
            contentView.arrangeViews {
                views
            }
        }
    }
    
    internal class LazyFishCollectionViewHeader: UICollectionReusableView {
        func updateContents(views: [UIView]) {
            for i in subviews {
                i.removeFromSuperview()
            }
            arrangeViews {
                views
            }
        }
    }
    
    private class DataSourceDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        var sections: [Section]
        var diffableDataSource: UICollectionViewDataSource?
        init(sections: [Section], collectionView: UICollectionView) {
            self.sections = sections
            super.init()
            
            collectionView.register(LazyFishCollectionViewCell.self, forCellWithReuseIdentifier: "LazyFishCollectionViewCell")
            collectionView.register(LazyFishCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "LazyFishCollectionViewHeader")
            collectionView.register(LazyFishCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "LazyFishCollectionViewHeader")
            
            if #available(iOS 13.0, *) {
                let dataSource = UICollectionViewDiffableDataSource<Section, Section.Item>(collectionView: collectionView) { [weak self] tableView, indexPath, itemIdentifier in
                    return self?.collectionView(collectionView, cellForItemAt: indexPath)
                }
                dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
                    return self?.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
                }
                self.diffableDataSource = dataSource
                
                var snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>()
                snapshot.appendSections(sections)
                for section in sections {
                    snapshot.appendItems(section.items, toSection: section)
                }
                dataSource.apply(snapshot)
                collectionView.dataSource = dataSource
                for (element) in sections {
                    element.didUpdate = { [weak element, weak dataSource] in
                        if let element = element, let dataSource = dataSource {
                            var snap = dataSource.snapshot()
                            let allItemsInSection = snap.itemIdentifiers(inSection: element)
                            snap.deleteItems(allItemsInSection)
                            snap.appendItems(element.items, toSection: element)
                            dataSource.apply(snap, animatingDifferences: true)
                        }
                    }
                }
            } else {
                collectionView.dataSource = self
                for (index, element) in sections.enumerated() {
                    element.didUpdate = { [weak self, weak collectionView] in
                        self?.removeHeaderCaches(section: index)
                        // 直接reloadData有bug
                        UIView.performWithoutAnimation {
                            collectionView?.reloadSections([index])
                        }
                    }
                }
            }
        }
        
        // MARK: ROWS
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return sections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return sections[section].contentInset
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return sections[section].rowCount
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cellId = "LazyFishCollectionViewCell"
            let section = sections[indexPath.section]
            let row = indexPath.row
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? LazyFishCollectionViewCell ?? LazyFishCollectionViewCell()
            cell.updateContents(views: section.items[row].content())
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            sections[indexPath.section].items[indexPath.row].didClick()
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
        // MARK: HEADERS
        private var lastRequestHeaders: [String: [Int: UICollectionReusableView]] = [:]
        
        func removeHeaderCaches(section: Int) {
            lastRequestHeaders.removeAll() // removeAll保险一点点
//            lastRequestHeaders[UICollectionView.elementKindSectionHeader]?[section] = nil
//            lastRequestHeaders[UICollectionView.elementKindSectionFooter]?[section] = nil
        }
        
        private func myCacheCollectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if let cac = lastRequestHeaders[kind]?[indexPath.section] {
                return cac
            }
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LazyFishCollectionViewHeader", for: indexPath) as? LazyFishCollectionViewHeader ?? LazyFishCollectionViewHeader()
            if kind == UICollectionView.elementKindSectionHeader {
                header.updateContents(views: sections[indexPath.section].headerViewsGetter?() ?? [])
                lastRequestHeaders[kind, default: [:]][indexPath.section] = header
            } else {
                header.updateContents(views: sections[indexPath.section].footerViewsGetter?() ?? [])
                lastRequestHeaders[kind, default: [:]][indexPath.section] = header
            }
            return header
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            return myCacheCollectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            let headerView = myCacheCollectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: .init(row: 0, section: section))
            return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
            let footerView = myCacheCollectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at: .init(row: 0, section: section))
            return footerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        }
    }
}

class SLCollectionViewGridLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let superAttrs = super.layoutAttributesForElements(in: rect) ?? []
        let cellsAttrs = superAttrs.filter { attr in
            return attr.representedElementCategory == .cell
        }
        balanceCells(attributes: cellsAttrs)
        return superAttrs
    }
    
    private func balanceCells(attributes: [UICollectionViewLayoutAttributes]) {
        var rowsAttrs = [[UICollectionViewLayoutAttributes]]()
        var sameRows = [UICollectionViewLayoutAttributes]()
        var lastAttr: UICollectionViewLayoutAttributes? = nil
        
        for attr in attributes {
            if lastAttr == nil {
                lastAttr = attr
                sameRows.append(attr)
                continue
            }
            
            var lastFrame = lastAttr?.frame ?? .zero
            var thisFrame = attr.frame
            lastFrame.origin.x = 0
            thisFrame.origin.x = 0
            if lastFrame.intersects(thisFrame) == false {
                rowsAttrs.append(sameRows)
                sameRows.removeAll()
            }
            lastAttr = attr
            sameRows.append(attr)
        }
        rowsAttrs.append(sameRows)
        
        for rows in rowsAttrs {
            alignRow(rows)
        }
    }
    
    private func alignRow(_ attributes: [UICollectionViewLayoutAttributes]) {
        var maxHeight: CGFloat = 0
        var minY: CGFloat = .infinity
        
        for attr in attributes {
            let testHeight = attr.frame.size.height
            let testY = attr.frame.origin.y
            if testHeight > maxHeight {
                maxHeight = testHeight
            }
            if testY < minY {
                minY = testY
            }
        }
        
        for attr in attributes {
            var frame = attr.frame
            frame.origin.y = minY
            attr.frame = frame
        }
        
        alignCellLeftForSameRow(attributes)
    }
    
    private func alignCellLeftForSameRow(_ attributes: [UICollectionViewLayoutAttributes]) {
        guard let collectionView = collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
            return
        }
        guard var last = attributes.first else {
            return
        }
        let sectionLeft = delegate.collectionView?(collectionView, layout: self, insetForSectionAt: last.indexPath.section).left ?? sectionInset.left
        
        var firstFrame = last.frame
        firstFrame.origin.x = sectionLeft
        last.frame = firstFrame
        
        
        let minSpace = delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: last.indexPath.section) ?? minimumInteritemSpacing
        
        guard attributes.count > 1 else {
            return
        }
        for i in 1..<attributes.count {
            let thisAttr = attributes[i]
            var fr = thisAttr.frame
            fr.origin.x = last.frame.maxX + minSpace
            thisAttr.frame = fr
            last = thisAttr
        }
    }
}

