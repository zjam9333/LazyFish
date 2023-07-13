//
//  CollectionViewTestViewController.swift
//  LazyFishTest
//
//  Created by zjj on 2023/7/12.
//

import UIKit
import LazyFishCore

class CollectionViewTestViewController: UIViewController {
    
    @State var arr = Array((0...4))
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.arrangeViews {
            UICollectionView {
                // 动态section
                Section(binding: $arr) { str in
                    UIStackView(axis: .horizontal, spacing: 10) {
                        if #available(iOS 13.0, *) {
                            UIImageView(image: UIImage(systemName: "person.fill.checkmark"))
                                .property(\.contentMode, value: .center)
                        }
                        UILabel()
                            .text("row: \(str)")
                            .backgroundColor(.white)
                    }
                    .padding(5 + CGFloat(str * 2))
                    .backgroundColor(.lightGray)
                    .cornerRadius(5)
                } action: { str in
                    print(str)
                }
                .headerViews {
                    UIView().frame(width: 100, height: 40).backgroundColor(.red)
                }
                .contentInset {
                    return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                }
                
                // 静态section
                Section(Array(0...50)) { str in
                    UILabel()
                        .text("row: \(str)")
                        .padding(10)
                        .backgroundColor(.lightGray)
                        .cornerRadius(5)
                } action: { str in
                    print(str)
                }
                .contentInset {
                    return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
        arr.append(Int.random(in: 0...10))
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
