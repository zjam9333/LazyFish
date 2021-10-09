//
//  Test3ViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import UIKit

class MarginTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.arrangeViews {
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
                        .margin(leading: 10, trailing: 10)
                        .frame(alignment: .allEdges)
                    }
                    .backgroundColor(.green)
                    .margin(top: 40, leading: 40, bottom: 40, trailing: 40).frame(alignment: .allEdges)
                }
                .backgroundColor(.systemRed)
                .margin(top: 40, leading: 40, bottom: 40, trailing: 40).frame(alignment: .allEdges)
            }
            .backgroundColor(.systemBlue)
            .margin(top: 40, leading: 40, bottom: 40, trailing: 40).frame(alignment: .allEdges)
        }
    }
}
