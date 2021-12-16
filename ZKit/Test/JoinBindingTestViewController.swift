//
//  JoinBindingTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/12/16.
//

import UIKit
import ZKitCore

class JoinBindingTestViewController: UIViewController {

    @State var text1: String = "abc"
    @State var text2: String = "123"
    @State var number3: Int = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let joined2Ojb: Binding<(String, Int)> = $text1.join($number3)
//        joined2Ojb.map { <#(String, Int)#> in
//            <#code#>
//        }
//
//        let joined3Obj_: Binding<(String, (String, Int))> = $text1.join($text2.join($number3))
//        joined3Obj_.map { <#(String, (String, Int))#> in
//            <#code#>
//        }
        
        let joined3Obj = $text1.join($text2).join($number3)
        
        let joinedMapString = joined3Obj.map { obj in
            return "\(obj)"
        }
        view.arrangeViews {
            UIView() {
                UIStackView(axis: .vertical, spacing: 10) {
                    UILabel().text("joined input result:")
                    UILabel().text(binding: joinedMapString)
                    UITextField().text(binding: $text1, changed: { [weak self] t in
                        self?.text1 = t
                    }).borderStyle(.roundedRect)
                    UITextField().text(binding: $text2, changed: { [weak self] t in
                        self?.text2 = t
                    }).borderStyle(.roundedRect)
                }
                .padding(top: 10, leading: 10, bottom: 10, trailing: 10)
                .alignment(.allEdges)
            }
            .borderWidth(1)
            .borderColor(.black)
            .frame(width: 300)
            .alignment(.top, value: 160)
            .alignment(.centerX, value: 0)
        }
        // Do any additional setup after loading the view.
    }
}
