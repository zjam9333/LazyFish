//
//  TableViewTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/11/2.
//

import UIKit

class TableViewTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.arrangeViews {
            UITableView(style: .plain) {
                for i in 0..<100 {
                    UIView {
                        UIStackView(axis: .horizontal, spacing: 10) {
                            if #available(iOS 13.0, *) {
                                UIImageView(image: UIImage(systemName: "person.fill.checkmark"))
//                                    .frame(width: 32, height: 32)
                            }
                            UILabel()
                                .text("row: \(i)")
                        }
                        .alignment(.leading, value: 20)
                        .alignment(.centerY)
                    }
//                    .frame(height: 44 + CGFloat(i))
                    .alignment(.allEdges)
                }
            }.alignment(.allEdges)
        }
        // Do any additional setup after loading the view.
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
