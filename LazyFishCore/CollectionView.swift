//
//  CollectionView.swift
//  LazyFishCore
//
//  Created by zjj on 2023/7/12.
//

import UIKit

public protocol LazyCollectionViewConfigProtocol {
    associatedtype SectionType: SectionProtocol
    
    var collectionViewLayout: UICollectionViewLayout { get }
    
    func cellFor(collectionView: UICollectionView, indexPath: IndexPath, item: SectionType.ItemType) -> UICollectionViewCell
    func supplymentFor(collectionView: UICollectionView, kind: String, indexPath: IndexPath, item: SectionType) -> UICollectionReusableView
    func collectionViewConfig(_ collectionView: UICollectionView)
}

public extension UICollectionView {
    
    convenience init(@ArrayBuilder<Section> sectionBuilder: () -> [Section]) {
        self.init(customConfigure: LazyCollectionView.DefaultConfig(), sectionBuilder: sectionBuilder)
    }
    
    // 若干个section
    convenience init<LazyConfigType: LazyCollectionViewConfigProtocol>(customConfigure config: LazyConfigType, @ArrayBuilder<LazyConfigType.SectionType> sectionBuilder: () -> [LazyConfigType.SectionType]) {
        self.init(frame: .zero, collectionViewLayout: config.collectionViewLayout)
        self.backgroundColor = UIColor.white
        self.alwaysBounceVertical = true
        config.collectionViewConfig(self)
        let sections = sectionBuilder()
        let delegate = LazyCollectionView.DataSource(sections: sections, collectionView: self, config: config)
        self.delegate = delegate
        
        // 仅仅是为了引用，不会读取
        objc_setAssociatedObject(self, &DelegateKey.attributeKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private enum DelegateKey {
        static var attributeKey: Int = 0
    }
}

enum LazyCollectionView {
    
    class CollectionViewCell: UICollectionViewCell {
        func updateContents(views: [UIView]) {
//            self.selectedBackgroundView = UIView().backgroundColor(.lightGray)
            for i in contentView.subviews {
                i.removeFromSuperview()
            }
            contentView.arrangeViews {
                views
            }
        }
    }
    
    class CollectionViewHeader: UICollectionReusableView {
        func updateContents(views: [UIView]) {
            for i in subviews {
                i.removeFromSuperview()
            }
            arrangeViews {
                views
            }
        }
    }
    
    class CellRegister<CellType: UICollectionViewCell, Item> {
        var didRegisted = false
        let id = UUID().uuidString
        
        let cellUpdate: (CellType, Item) -> Void
        
        init(cellUpdate: @escaping (CellType, Item) -> Void) {
            self.cellUpdate = cellUpdate
        }
        
        func cellFor(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
            if didRegisted == false {
                collectionView.register(CellType.self, forCellWithReuseIdentifier: id)
                didRegisted = true
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
            if let cell = cell as? CellType {
                cellUpdate(cell, item)
            }
            return cell
        }
    }
    
    class SupplymentRegister<CellType: UICollectionReusableView, Item> {
        var didRegistedKinds = Set<String>()
        let kind: String
        let id = UUID().uuidString
        
        let cellUpdate: (CellType, Item) -> Void
        
        init(kind: String, cellUpdate: @escaping (CellType, Item) -> Void) {
            self.kind = kind
            self.cellUpdate = cellUpdate
        }
        
        func supplymentFor(collectionView: UICollectionView, kind: String, indexPath: IndexPath, item: Item) -> UICollectionReusableView {
            if didRegistedKinds.contains(kind) == false {
                collectionView.register(CellType.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
                didRegistedKinds.insert(kind)
            }
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath)
            if let cell = cell as? CellType {
                cellUpdate(cell, item)
            }
            return cell
        }
    }
    
    struct DefaultConfig: LazyCollectionViewConfigProtocol {
        func collectionViewConfig(_ collectionView: UICollectionView) {
            
        }
        
        func cellFor(collectionView: UICollectionView, indexPath: IndexPath, item: Section.Item) -> UICollectionViewCell {
            cellRegister.cellFor(collectionView: collectionView, indexPath: indexPath, item: item)
        }
        
        func supplymentFor(collectionView: UICollectionView, kind: String, indexPath: IndexPath, item: Section) -> UICollectionReusableView {
            if kind == headerRegister.kind {
                return headerRegister.supplymentFor(collectionView: collectionView, kind: kind, indexPath: indexPath, item: item)
            } else if kind == footerRegister.kind {
                return footerRegister.supplymentFor(collectionView: collectionView, kind: kind, indexPath: indexPath, item: item)
            }
            return UICollectionReusableView()
        }
        
        let cellRegister = CellRegister<CollectionViewCell, Section.Item>.init { cell, item in
            cell.updateContents(views: item.content())
        }
        
        let headerRegister = SupplymentRegister<CollectionViewHeader, Section>.init(kind: UICollectionView.elementKindSectionHeader) { header, section in
            header.updateContents(views: section.headerViewsGetter?() ?? [])
        }
        
        let footerRegister = SupplymentRegister<CollectionViewHeader, Section>.init(kind: UICollectionView.elementKindSectionFooter) { header, section in
            header.updateContents(views: section.footerViewsGetter?() ?? [])
        }
        
        var collectionViewLayout: UICollectionViewLayout {
            if #available(iOS 13.0, *) {
                let config = UICollectionViewCompositionalLayoutConfiguration()
                config.interSectionSpacing = 10
                config.scrollDirection = .vertical
                
                return UICollectionViewCompositionalLayout(sectionProvider: { section, sectionEnv in
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), subitems: [
                        .init(layoutSize: .init(widthDimension: .estimated(40), heightDimension: .fractionalHeight(1)))
                    ])
                    group.interItemSpacing = .fixed(10)
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = 10
                    section.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
                    section.boundarySupplementaryItems = [
                        NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44)), elementKind: headerRegister.kind, alignment: .top),
                        NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .absolute(44)), elementKind: footerRegister.kind, alignment: .bottomTrailing),
                    ]
                    return section
                }, configuration: config)
            } else {
                let layout = UICollectionViewFlowLayout()
                layout.headerReferenceSize = CGSize(width: 300, height: 40)
                layout.footerReferenceSize = CGSize(width: 300, height: 40)
                layout.estimatedItemSize = CGSize(width: 40, height: 40)
                layout.sectionInset = .init(top: 20, left: 20, bottom: 20, right: 20)
                return layout
            }
        }
    }
    
    class DataSource<LazyConfigType: LazyCollectionViewConfigProtocol>: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
        
        var sections: [LazyConfigType.SectionType]
        var diffableDataSource: UICollectionViewDataSource?
        let config: LazyConfigType
        init(sections: [LazyConfigType.SectionType], collectionView: UICollectionView, config: LazyConfigType) {
            self.config = config
            self.sections = sections
            super.init()
            
            if #available(iOS 13.0, *) {
                let dataSource = UICollectionViewDiffableDataSource<LazyConfigType.SectionType, LazyConfigType.SectionType.ItemType>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
                    return self?.collectionView(collectionView, cellForItemAt: indexPath)
                }
                dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
                    return self?.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
                }
                self.diffableDataSource = dataSource
                
                var snapshot = NSDiffableDataSourceSnapshot<LazyConfigType.SectionType, LazyConfigType.SectionType.ItemType>()
                snapshot.appendSections(sections)
                for section in sections {
                    snapshot.appendItems(section.items, toSection: section)
                }
                dataSource.apply(snapshot, animatingDifferences: false) {
                    // 这个才能在iOS13运行
                }
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
                    element.didUpdate = { [weak collectionView] in
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
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return sections[section].items.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let item = sections[indexPath.section].items[indexPath.row]
            let cell = config.cellFor(collectionView: collectionView, indexPath: indexPath, item: item)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            sections[indexPath.section].didClick(indexPath.row)
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
        // MARK: HEADERS
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            let section = sections[indexPath.section]
            return config.supplymentFor(collectionView: collectionView, kind: kind, indexPath: indexPath, item: section)
        }
    }
}

