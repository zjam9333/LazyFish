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
                        .padding(leading: 10, trailing: 10)
                        .alignment(.allEdges)
                    }
                    .backgroundColor(.green)
                    .padding(top: 40, leading: 40, bottom: 40, trailing: 40).alignment(.allEdges)
                }
                .backgroundColor(.systemRed)
                .padding(top: 40, leading: 40, bottom: 40, trailing: 40).alignment(.allEdges)
            }
            .backgroundColor(.systemBlue)
            .padding(top: 40, leading: 40, bottom: 40, trailing: 40).alignment(.allEdges)
        }
    }
}
