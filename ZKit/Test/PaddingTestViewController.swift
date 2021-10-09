//
//  Test3ViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import UIKit

class PaddingTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.arrangeViews {
            let v = UIView {
                let v = UIView {
                    let v = UIView {
                        
                    }
                    v.backgroundColor = .green
                    v.margin(top: 40, leading: 40, bottom: 40, trailing: 40).frame(alignment: .allEdges)
                }
                v.backgroundColor = .systemRed
                v.margin(top: 40, leading: 40, bottom: 40, trailing: 40).frame(alignment: .allEdges)
            }
            v.backgroundColor = .systemBlue
            v.margin(top: 40, leading: 40, bottom: 40, trailing: 40).frame(alignment: .allEdges)
        }
    }
}
