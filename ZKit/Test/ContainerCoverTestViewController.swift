//
//  ContainerCoverTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/12/6.
//

import UIKit
import ZKitCore

class ContainerCoverTestViewController: UIViewController {

    @State var condition: Bool = true
    @State var array: [Int] = [1, 2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.arrangeViews {
            UILabel()
                .text("Check the Touch Event, there are a IfView and a ForEachView covered the whole Screen")
                .numberOfLines(0)
                .backgroundColor(.lightGray)
                .textColor(.black)
                .alignment(.centerX)
                .alignment(.bottom, value: -64)
                .frame(width: 200)
            
            UIStackView(axis: .vertical, alignment: .leading, spacing: 5) {
                UILabel("If In Stack")
                IfBlock($condition) {
                    UIButton("ButtonOnStackIf")
                        .textColor(.magenta)
                        .action {
                            print("StackIf Button Click")
                        }
                }
                
                UILabel("ForEach In Stack")
                ForEachEnumerated($array) { index, obj in
                    UIButton("ButtonOnStackForEach \(index)")
                        .textColor(.magenta)
                        .action {
                            print("StackForEach Button Click \(index)")
                        }
                }
            }
            .alignment([.leading], value: 100)
            .alignment([.top], value: 300)
            
            UIButton("ButtonOnBG level 0")
                .textColor(.red)
                .alignment([.leading], value: 100)
                .alignment([.top], value: 100)
                .action {
                    print("BG Button Click")
                }
            
            IfBlock($condition) {
                UIButton("ButtonOnIf level 1")
                    .textColor(.green)
                    .alignment([.leading], value: 100)
                    .alignment([.top], value: 140)
                    .action {
                        print("If Button Click")
                    }
            }
            
            ForEachEnumerated($array) { index, obj in
                UIButton("ButtonOnForEach level 2")
                    .textColor(.blue)
                    .alignment([.leading], value: 100)
                    .alignment([.top], value: 180)
                    .action {
                        print("ForEach Button Click")
                    }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("view background Click")
    }

}
