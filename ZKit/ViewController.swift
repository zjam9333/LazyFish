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
        
        let testClasses: [(name: String, classType: UIViewController.Type)] = [
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
            UICollectionView(array: testClasses) { item in
                let title = item.name
                UILabel().text(title).font(.systemFont(ofSize: 17, weight: .regular)).textColor(.black)
                    .border(width: 1, color: .black)
                    .textAlignment(.center)
                    .numberOfLines(0)
                    .frame(width: 72, height: 64)
                    .alignment(.allEdges).padding(10)
            } action: { [weak self] item in
                let vc = item.classType.init()
                vc.view.backgroundColor = .white
                vc.navigationItem.title = item.name
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .alignment(.allEdges)
        }
    }
}

