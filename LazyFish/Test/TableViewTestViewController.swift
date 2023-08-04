//
//  TableViewTestViewController.swift
//  LazyFish
//
//  Created by zjj on 2021/11/2.
//

import UIKit
import LazyFishCore

class TableViewTestViewController: UIViewController {
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
            UITableView(style: .grouped) {
                // 动态section
                Section(binding: $arr) { str in
                    UIStackView(axis: .horizontal, spacing: 10) {
                        if #available(iOS 13.0, *) {
                            UIImageView(image: UIImage(systemName: "person.fill.checkmark"))
//                                    .frame(width: 32, height: 32)
                        }
                        UILabel("row: \(str.value)")
                    }
                    .alignment(.leading, value: 20)
                    .alignment(.centerY)
                    
                    if #available(iOS 13.0, *) {
                        UIImageView(image: UIImage(systemName: "chevron.right"))
                            .alignment(.trailing, value: -10)
                            .alignment(.centerY)
                    }
                    
                    UIView()
                        .backgroundColor(UIColor.lightGray.withAlphaComponent(0.5))
                        .frame(height: 0.5)
                        .alignment([.bottom, .trailing])
                        .alignment(.leading, value: 20)
                } action: { [weak self] it in
                    self?.arr.removeAll { e in
                        e == it
                    }
                }
                // header footer 展示
                .headerViews {
                    UIStackView(axis: .horizontal, spacing: 10) {
                        if #available(iOS 13.0, *) {
                            UIImageView(image: UIImage(systemName: "flame.fill")).frame(width: 32, height: 32)
                        }
                        UILabel().text("Some Section Header").font(UIFont.systemFont(ofSize: 24, weight: .bold))
                    }
                    .padding(5)
                }
                .footerViews {
                    UILabel().text("Some footer")
                        .frame(height: 30)
                        .padding(5)
                        .backgroundColor(.red)
                }
                
                // 静态section
                Section(Array(0...4)) { str in
                    UILabel()
                        .text("row: \(str)")
                        .alignment(.leading, value: 20)
                        .alignment(.centerY)
                    
                    UIView()
                        .backgroundColor(UIColor.lightGray.withAlphaComponent(0.5))
                        .frame(height: 0.5)
                        .alignment([.bottom, .trailing])
                        .alignment(.leading, value: 20)
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
        arr.append(.init(value: Int.random(in: 0...255)))
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
