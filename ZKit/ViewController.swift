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
        
        navigationItem.title = "Some Tests"
        
        typealias VCModel = (name: String, classType: UIViewController.Type)
        var testClasses: [VCModel] = [
            ("Join Binding Test", JoinBindingTestViewController.self),
            ("Product Detail Test", ProductDetailTestViewController.self),
            ("Container Cover Test", ContainerCoverTestViewController.self),
            ("Observe Remove Test", ObserveRemoveTestViewController.self),
            ("PPT Test", PPTTestViewController.self),
            ("TableView Test", TableViewTestViewController.self),
            ("ForEach In Stack Test", ForEachTestViewController.self),
            ("ForEach In Scroll Test", ForEachScrollTestViewController.self),
            ("Page Test", PageTestViewController.self),
            ("Alert Test", AlertTestViewController.self),
            ("Demo Test", DemoTestViewController.self),
            ("State Test", StateTestViewController.self),
            ("Input Test", InputTestViewController.self),
//            ("Stack Test", StackTestViewController.self),
            ("Margin Test", MarginTestViewController.self),
        ]
        testClasses.append(contentsOf: Array<VCModel>(repeating: ("Ram", ViewController.self), count: 1000))
        
        view.arrangeViews {
            UITableView(style: .plain, array: testClasses) { item in
                let title = item.name
                UILabel().text(title).font(.systemFont(ofSize: 17, weight: .regular)).textColor(.black)
                    .alignment(.allEdges)
                    .padding(20)
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

