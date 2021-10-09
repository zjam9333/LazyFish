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
            ("Margin Test", MarginTestViewController.self),
        ]
        
        self.view.arrangeViews {
            UIScrollView(.vertical) {
                UIStackView(axis: .vertical, distribution: .fill, alignment: .fill, spacing: 10) {
                    for (key, val) in testClasses {
                        let title = key
                        UIButton()
                            .text(title)
                            .textColor(.black)
                            .textColor(.red, for: .highlighted)
                            .font(UIFont.systemFont(ofSize: 20, weight: .bold))
                            .backgroundColor(.lightGray)
                            .frame(height: 50, alignment: .allEdges)
                            .borderWidth(1).borderColor(.black)
                            .action { [weak self] in
                                let vc = val.init()
                                vc.view.backgroundColor = .white
                                vc.navigationItem.title = title
                                self?.navigationController?.pushViewController(vc, animated: true)
                            }
                    }
                }
                .margin(top: 10, leading: 10, bottom: 10, trailing: 10)
            }
            .frame(alignment: .allEdges)
            .bounce(.vertical)//.bounce(.horizontal)
        }
    }
}

