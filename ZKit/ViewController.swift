//
//  ViewController.swift
//  ZKit
//
//  Created by zjj on 2021/9/29.
//

import UIKit
import ZKitCore

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Some Tests"
        
        let testClasses: [(String, UIViewController.Type)] = [
            ("TableView Test", TableViewTestViewController.self),
            ("ForEach In Stack Test", ForEachTestViewController.self),
            ("ForEach In Scroll Test", ForEachScrollTestViewController.self),
            ("Page Test", PageTestViewController.self),
            ("Alert Test", AlertTestViewController.self),
            ("Demo Test", DemoTestViewController.self),
            ("State Test", StateTestViewController.self),
            ("Input Test", InputTestViewController.self),
            ("Stack Test", StackTestViewController.self),
            ("Margin Test", MarginTestViewController.self),
        ]
        
        self.view.arrangeViews {
            UIScrollView(.vertical) {
                    for (key, val) in testClasses {
                        let title = key
                        UIView {
                            UILabel().text(title).font(.systemFont(ofSize: 17, weight: .regular)).textColor(.black)
                                .alignment(.centerY)
                                .alignment(.leading, value: 20)
                            if #available(iOS 13.0, *) {
                                UIImageView(image: UIImage(systemName: "chevron.right"))
                                    .alignment([.trailing, .centerY])
                                    .offset(x: -10, y: 0)
                            }
                            UIView().backgroundColor(.gray)
                                .alignment([.bottom, .trailing], value: 0)
                                .alignment(.leading, value: 20)
                                .frame(height: 0.5)
                            UIButton()
                                .action { [weak self] in
                                    let vc = val.init()
                                    vc.view.backgroundColor = .white
                                    vc.navigationItem.title = title
                                    self?.navigationController?.pushViewController(vc, animated: true)
                                }
                                .alignment(.allEdges)
                        }
                        .frame(height: 50)
                    }
            }
            .alignment(.allEdges)
            .bounce(.vertical)//.bounce(.horizontal)
        }
    }
}

