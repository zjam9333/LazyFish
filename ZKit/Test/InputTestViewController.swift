//
//  InputTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/22.
//

import UIKit

class InputTestViewController: UIViewController {
    
    @ZKit.State var text: String = "abc"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.arrangeViews {
            UIView() {
                UIStackView(axis: .vertical, spacing: 10) {
                    UILabel().text("your input:")
                    UILabel().text(self.$text)
                    UITextField().text(self.$text).borderStyle(.roundedRect)
                }
                .padding(top: 10, leading: 10, bottom: 10, trailing: 10)
            }
            .borderWidth(1)
            .borderColor(.black)
            .alignment([.top, .centerX])
            .frame(width: 200)
            .padding(top: 160)
        }
        // Do any additional setup after loading the view.
    }
}
