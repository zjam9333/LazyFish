//
//  ViewController.swift
//  ZKit
//
//  Created by zjj on 2021/9/29.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let testClasses: [(String, UIViewController.Type)] = [
            ("Alert View Test", AlertTestViewController.self),
            ("Stack Test", StackTestViewController.self),
            ("Padding Test", PaddingTestViewController.self),
        ]
        
        self.view.arrangeViews {
            UIScrollView(.vertical) {
                UIStackView(axis: .vertical, distribution: .fill, alignment: .fill, spacing: 10) {
                    for (key, val) in testClasses {
                        let title = key
                        UIButton()
                            .text(title)
                            .textColor(.black)
                            .font(UIFont.systemFont(ofSize: 20, weight: .bold))
                            .backgroundColor(.lightGray)
                            .action { [weak self] in
                                let vc = val.init()
                                vc.view.backgroundColor = .white
                                vc.navigationItem.title = title
                                self?.navigationController?.pushViewController(vc, animated: true)
                            }
                            .frame(height: 50, alignment: .allEdges)
                    }
                }
                .margin(top: 10, leading: 10, bottom: 10, trailing: 10)
            }.frame(alignment: .allEdges)
        }
    }
}

