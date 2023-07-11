//
//  GeoTestViewController.swift
//  LazyFishTest
//
//  Created by zjj on 2022/1/18.
//

import UIKit
import LazyFishCore

class GeoTestViewController: UIViewController {

    @State var textValue: String = "100"
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.arrangeViews {
            let bi = $textValue.map { str in
                return CGFloat(Int(str) ?? 0)
            }
            GeometryReader { geo in
                UIButton("ABC")
                    .action {
                        print("button")
                    }
                    .frame(width: geo.size.width / 2, height: geo.size.height - 30 * 2)
                    .backgroundColor(.red)
//                    .alignment([.center])
                    .alignment([.top, .leading], value: 100)
            }
            .frame(width: bi, height: bi)
            .backgroundColor(.blue)
            .alignment(.top, value: 100)
            .alignment(.leading, value: 10)
            
            UITextField().borderStyle(.roundedRect).text(binding: $textValue) { [weak self] tt in
                ActionWithAnimation(.curveEaseInOut(duration: 0.25)) {
                    self?.textValue = tt
                    self?.view.layoutIfNeeded()
                }
            }
            .frame(width: 100)
            .alignment([.centerX, .bottom])
            .alignment(.bottom, value: -20)
        }
        // Do any additional setup after loading the view.
    }

}
