//
//  Test3ViewController.swift
//  LazyFish
//
//  Created by zjj on 2021/10/8.
//

import UIKit

class MarginTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.arrangeViews {
            UIView {
                UIView {
                    UIView {
                        UIStackView(axis: .vertical, distribution: .fillEqually) {
                            for _ in 0...10 {
                                UIView()
                                    .backgroundColor(UIColor(hue: CGFloat.random(in: 0...1), saturation: 1, brightness: 1, alpha: 1))
                                    .borderColor(.black)
                                    .borderWidth(1)
                            }
                        }
                        .padding(horizontal: 10)
                    }
                    .backgroundColor(.green)
                    .padding(40)
                }
                .backgroundColor(.systemRed)
                .padding(40)
            }
            .backgroundColor(.systemBlue)
            .padding(40)
        }
    }
}
