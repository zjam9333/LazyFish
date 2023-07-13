//
//  CollectionView.swift
//  LazyFishCore
//
//  Created by zjj on 2023/7/12.
//

import UIKit

public extension UICollectionView {
    
    // 若干个section
    convenience init(@ArrayBuilder<Section> sectionBuilder: ArrayBuilder<Section>.ContentBlock) {
        let flowLayout = SLCollectionViewGridLayout()
        flowLayout.estimatedItemSize = CGSize(width: 40, height: 40)
        self.init(frame: .zero, collectionViewLayout: flowLayout)
        self.alwaysBounceVertical = true
        self.register(LazyFishCollectionViewCell.self, forCellWithReuseIdentifier: "LazyFishCollectionViewCell")
        let delegate = DataSourceDelegate()
        self.delegate = delegate
        self.dataSource = delegate
        zk_collectionViewViewDelegate = delegate
        delegate.sections = sectionBuilder()
        for (_, element) in delegate.sections.enumerated() {
            element.didUpdate = { [weak self] in
                self?.reloadData()
            }
        }
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
    
    private class DataSourceDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SLCollectionViewDelegateGridLayout {
        
        var sections: [Section] = []
        
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
            cell.updateContents(views: section.content?(row) ?? [])
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            sections[indexPath.section].didClick?(indexPath.row)
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldAlignSameRowCellHeight indexPath: IndexPath) -> Bool {
            return false
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldAlignSameRowCellLeft indexPath: IndexPath) -> Bool {
            return true
        }
    }
}

protocol SLCollectionViewDelegateGridLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, shouldAlignSameRowCellHeight indexPath: IndexPath) -> Bool
    func collectionView(_ collectionView: UICollectionView, shouldAlignSameRowCellLeft indexPath: IndexPath) -> Bool
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
            alignCellLeftForSameRow(rows)
            alignCellHeightForSameRow(rows)
        }
    }
    
    private func alignCellHeightForSameRow(_ attributes: [UICollectionViewLayoutAttributes]) {
        guard let collectionView = collectionView, let delegate = collectionView.delegate as? SLCollectionViewDelegateGridLayout else {
            return
        }
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
            let shouldAlignHeight = delegate.collectionView(collectionView, shouldAlignSameRowCellHeight: attr.indexPath)
            if shouldAlignHeight {
                var frame = attr.frame
                frame.origin.y = minY
                frame.size.height = maxHeight
                attr.frame = frame
            }
        }
    }
    
    private func alignCellLeftForSameRow(_ attributes: [UICollectionViewLayoutAttributes]) {
        guard let collectionView = collectionView, let delegate = collectionView.delegate as? SLCollectionViewDelegateGridLayout else {
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
            let shouldAlignLeft = delegate.collectionView(collectionView, shouldAlignSameRowCellLeft: thisAttr.indexPath)
            if shouldAlignLeft {
                var fr = thisAttr.frame
                fr.origin.x = last.frame.maxX + minSpace
                thisAttr.frame = fr
            }
            last = thisAttr
        }
    }
}

