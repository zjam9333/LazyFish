//
//  CollectionViewTestViewController.swift
//  LazyFishTest
//
//  Created by zjj on 2023/7/12.
//

import UIKit
import LazyFishCore

class CollectionViewTestViewController: UIViewController {
    struct Model: Hashable {
        let id = UUID()
        let value: Int
    }
    
    @State var arr: [Model] = Array((0...4).map({ i in
        return Model(value: i)
    }))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.arrangeViews {
            let layout: UICollectionViewLayout
            if #available(iOS 13.0, *) {
                let config = UICollectionViewCompositionalLayoutConfiguration()
                config.interSectionSpacing = 10
                config.scrollDirection = .vertical
                
                layout = UICollectionViewCompositionalLayout(sectionProvider: { section, sectionEnv in
                    let group = NSCollectionLayoutGroup.custom(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))) { groupEnv in
                        let groupSize = groupEnv.container.effectiveContentSize
                        // 返回多少个，每group就排多少个
                        return [
                            NSCollectionLayoutGroupCustomItem(frame: .init(x: 0, y: 0, width: groupSize.height - 20, height: groupSize.height - 20)),
                            NSCollectionLayoutGroupCustomItem(frame: .init(x: groupSize.width / 2 - 10, y: 0, width: groupSize.width / 2 - 30, height: groupSize.height / 2 - 10)),
                            NSCollectionLayoutGroupCustomItem(frame: .init(x: groupSize.width / 2 - 10, y: groupSize.height / 2, width: groupSize.width / 2 - 30, height: groupSize.height / 2 - 20)),
                        ]
                    }
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = 10
                    section.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
                    section.boundarySupplementaryItems = [
                        NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top),
                        NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .absolute(44)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottomTrailing),
                    ]
                    return section
                }, configuration: config)
            } else {
                layout = SLCollectionViewGridLayout()
                if let layout = layout as? SLCollectionViewGridLayout {
                    layout.estimatedItemSize = CGSize(width: 40, height: 40)
                }
            }
            UICollectionView(layout: layout) {
                // 动态section
                Section(binding: $arr) { str in
                    UILabel()
                        .text("row: \(str.value)\(Array.init(repeating: ".", count: str.value % 20 + 1).joined())")
                        .backgroundColor(.white)
                    .padding(5)
                    .border(width: 1, color: .white)
                    .padding(5)
                    .backgroundColor(.lightGray)
                    .cornerRadius(5)
                } action: { [weak self] str in
                    print("delete", str)
                    self?.arr.removeAll { e in
                        return str == e
                    }
                }
                .headerViews {
                    UILabel("TEST headder")
                        .padding(10).backgroundColor(.red)
                }
                .footerViews {
                    UILabel("TEST footer")
                        .padding(10).backgroundColor(.blue)
                }
                .contentInset {
                    return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                }
                
                ForEach(Array(0...5)) { i in
                    // 静态section
                    Section(Array(0...(i + 5))) { str in
                        UILabel()
                            .text("row: \(str)")
                            .padding(4 + CGFloat(abs(str.hashValue) % 5))
                            .backgroundColor(.lightGray)
                            .cornerRadius(5)
                    } action: { str in
                        print(str)
                    }
                    .headerViews {
                        UILabel("TEST headder 2 + \(i)")
                            .padding(10)
                            .backgroundColor(.green)
                    }
                    .footerViews {
                        UILabel("TEST footer 2 + \(i)")
                            .padding(10)
                            .backgroundColor(.yellow)
                    }
                    .contentInset {
                        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
