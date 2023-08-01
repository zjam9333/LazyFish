//
//  ViewController.swift
//  LazyFish
//
//  Created by zjj on 2021/9/29.
//

import UIKit
import LazyFishCore

class VCModel: Hashable {
    static func == (lhs: VCModel, rhs: VCModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    let id = UUID()
    
    let name: String
    let classType: UIViewController.Type
    init(_ name: String, _ classType: UIViewController.Type) {
        self.name = name
        self.classType = classType
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Some Tests"
        
        let arr: [(name: String, classType: UIViewController.Type)] = [
//            ("Geometry Test", GeoTestViewController.self),
            ("Alert Test", AlertTestViewController.self),
            ("Join Binding Test", JoinBindingTestViewController.self),
            ("Container Cover Test", ContainerCoverTestViewController.self),
            ("TableView Test", TableViewTestViewController.self),
            ("CollectionView Test", CollectionViewTestViewController.self),
            ("ForEach In Stack Test", ForEachTestViewController.self),
            ("Page Test", PageTestViewController.self),
            ("State Test", StateTestViewController.self),
        ]
        
        
        let testClasses = arr.map { c in
            return VCModel(c.name, c.classType)
        }
        
        view.arrangeViews {
            UITableView(style: .plain) {
                Section(testClasses) { item in
                    UILabel().text(item.name).font(.systemFont(ofSize: 17, weight: .regular)).textColor(.black)
                        .padding(10)
                    UIView()
                        .backgroundColor(UIColor.lightGray.withAlphaComponent(0.5))
                        .frame(height: 0.5)
                        .alignment([.bottom, .trailing])
                        .alignment(.leading, value: 10)
                } action: { [weak self] item in
                    let vc = item.classType.init()
                    vc.view.backgroundColor = .white
                    vc.navigationItem.title = item.name
                    self?.navigationController?.pushViewController(vc, animated: true)
                }.headerViews {
                    UILabel().text("Test Classes")
                        .padding(10)
                        .backgroundColor(.gray)
                }
                
                Section((0..<100).map({ i in
                    VCModel("Ram", ViewController.self)
                })) { item in
                    UILabel().text(item.name).font(.systemFont(ofSize: 17, weight: .regular)).textColor(.black)
                        .padding(10)
                    UIView()
                        .backgroundColor(UIColor.lightGray.withAlphaComponent(0.5))
                        .frame(height: 0.5)
                        .alignment([.bottom, .trailing])
                        .alignment(.leading, value: 10)
                } action: { [weak self] item in
                    let vc = item.classType.init()
                    vc.view.backgroundColor = .white
                    vc.navigationItem.title = item.name
                    self?.navigationController?.pushViewController(vc, animated: true)
                }.headerViews {
                    UILabel().text("Random Section")
                        .padding(10)
                        .backgroundColor(.gray)
                }.footerViews {
                    
                }
            }
        }
    }
}

