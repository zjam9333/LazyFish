//
//  CustomSectionCollectionViewController.swift
//  LazyFishTest
//
//  Created by zjj on 2023/8/7.
//

import UIKit
import LazyFishCore

class CustomSectionCollectionViewController: UIViewController {
    
    class CollectionViewCell: UICollectionViewCell {
        let label = UILabel()
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.arrangeViews {
                self.label.padding(5).border(width: 1, color: .black)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    struct Item: ItemProtocol {
        let id = UUID()
        let value: Int
    }
    
    @State private var arr: [Item] = Array((0...4).map({ i in
        return Item(value: i)
    }))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.arrangeViews {
            
            let config = CustomConfig<CollectionViewCell, CustomSection<Item>> { cell, item in
                cell.label.text = "val:\(item.value)"
            }
            
            UICollectionView(customConfigure: config) {
                // 动态section
                CustomSection(binding: $arr) { [weak self] str in
                    print("delete", str)
                    self?.arr.removeAll { e in
                        return str == e
                    }
                }

                ForEach(0...5) { i in
                    // 静态section
                    CustomSection(Array(0...(i + 5)).map({ t in
                        return Item(value: i)
                    })) { str in
                        print(str)
                    }
                }
            }
        }
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewObject)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(cleanObjects))
        ]
    }
    
    @objc func addNewObject() {
        arr.append(.init(value: Int.random(in: 0...10)))
    }
    
    @objc func cleanObjects() {
        arr.removeAll()
    }
}


// 不用默认Section，自定义SectionProtocol，写起来还是不好看

class CustomSection<Item: ItemProtocol>: SectionProtocol {
    
    public static func == (lhs: CustomSection, rhs: CustomSection) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var didUpdate: () -> Void = {}
    public private(set) var didClick: (Int) -> Void = { _ in }
    
    public private(set) var items: [Item] = []
    
    public init<S: RandomAccessCollection>(_ array: S, action: ((S.Element) -> Void)? = nil) where S.Element == Item {
        resetArray(array, action: action)
    }
    
    public init<S: RandomAccessCollection>(binding: Binding<S>?, action: ((S.Element) -> Void)? = nil) where S.Element == Item {
        binding?.addObserver(target: self) { [weak self] changed in
            // binding的array发生变化，则更新datasource
            let arr = changed.new
            self?.resetArray(arr, action: action)
            self?.didUpdate()
        }
    }
    
    private func resetArray<S: RandomAccessCollection>(_ array: S, action: ((S.Element) -> Void)? = nil) where S.Element == Item {
        if let action = action {
            let mapActions = array.map { ele in
                return {
                    action(ele)
                }
            }
            didClick = { i in
                mapActions[i]()
            }
        }
        items = Array(array)
    }
}

class CustomConfig<C: UICollectionViewCell, S: SectionProtocol>: LazyCollectionViewConfigProtocol {
    
    init(cellUpdate: @escaping (C, S.ItemType) -> Void) {
        self.cellUpdate = cellUpdate
    }
    
    var collectionViewLayout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 40, height: 40)
        layout.sectionInset = .init(top: 20, left: 20, bottom: 0, right: 20)
        return layout
    }
    let cellUpdate: (C, S.ItemType) -> Void
    let id = UUID().uuidString
    var didRegCell = false
    
    func cellFor(collectionView: UICollectionView, indexPath: IndexPath, item: S.ItemType) -> UICollectionViewCell {
        if didRegCell == false {
            collectionView.register(C.self, forCellWithReuseIdentifier: id)
            didRegCell = true
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
        if let cell = cell as? C {
            cellUpdate(cell, item)
        }
        return cell
    }
    
    func supplymentFor(collectionView: UICollectionView, kind: String, indexPath: IndexPath, item: S) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    func collectionViewConfig(_ collectionView: UICollectionView) {
        collectionView.backgroundColor = .init(white: 0.95, alpha: 1)
    }
}
