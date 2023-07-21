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
            UICollectionView {
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
                
                for i in 0...5 {
                    // 静态section
                    Section(Array(0...50)) { str in
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
