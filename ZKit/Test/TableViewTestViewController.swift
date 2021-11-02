//
//  TableViewTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/11/2.
//

import UIKit
import ZKitCore

class TableViewTestViewController: UIViewController {

    @State var arr = Array((0...10))
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.arrangeViews {
            UITableView(style: .plain) {
                TableViewSection($arr) { str in
                    UIView {
                        UIStackView(axis: .horizontal, spacing: 10) {
                            if #available(iOS 13.0, *) {
                                UIImageView(image: UIImage(systemName: "person.fill.checkmark"))
//                                    .frame(width: 32, height: 32)
                            }
                            UILabel()
                                .text("row: \(str)")
                        }
                        .alignment(.leading, value: 20)
                        .alignment(.centerY)
                        
                        if #available(iOS 13.0, *) {
                            UIImageView(image: UIImage(systemName: "chevron.right"))
                                .alignment(.trailing, value: -10)
                                .alignment(.centerY)
                        }
                    }
                    .alignment(.allEdges)
                }
                
            }.alignment(.allEdges)
        }
        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewObject)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(cleanObjects))
        ]
    }
    
    @objc func addNewObject() {
        self.arr.append(Int.random(in: 0...255))
    }
    
    @objc func cleanObjects() {
        self.arr.removeAll()
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
