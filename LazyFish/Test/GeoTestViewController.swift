//
//  GeoTestViewController.swift
//  LazyFishTest
//
//  Created by zjj on 2022/1/18.
//

import UIKit
import LazyFishCore

class GeoTestViewController: UIViewController {

    @State var slideValue: CGFloat = 0.5
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.arrangeViews {
            GeometryReader { geo in
                UIButton("ABC")
                    .onAction { b in
                        print("button")
                    }
                    .frame(width: geo.size.width / 2, height: geo.size.height / 3)
                    .backgroundColor(.red)
                    .alignment([.top, .leading], value: geo.size.width + geo.size.width * 0.2)
            }
            .frame(width: $slideValue * 200, height: $slideValue * 300)
            .backgroundColor(.blue)
            .alignment(.top, value: 100)
            .alignment(.leading, value: 10)
            
            UISlider()
                .property(\.value, value: Float(slideValue))
//                .property(\.isContinuous, value: false)
                .onAction(forEvent: .valueChanged) { [weak self] sli in
                    ActionWithAnimation(.curveLinear(duration: 0.25)) {
                        self?.slideValue = CGFloat(sli.value)
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
