//
//  InputTestViewController.swift
//  LazyFish
//
//  Created by zjj on 2021/10/22.
//

import UIKit
import LazyFishCore

class InputTestViewController: UIViewController {
    
    @State var text: String = "abc"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.arrangeViews {
            UIView() {
                UIStackView(axis: .vertical, spacing: 10) {
                    UILabel().text("your input:")
                    UILabel().text(binding: $text)
                    UITextField().text(binding: $text, changed: { [weak self] t in
                        self?.text = t
                    }).borderStyle(.roundedRect)
                }
                .padding(10)
            }
            .borderWidth(1)
            .borderColor(.black)
            .frame(width: 200)
            .alignment(.top, value: 160)
            .alignment(.centerX, value: 0)
        }
        // Do any additional setup after loading the view.
    }
}
