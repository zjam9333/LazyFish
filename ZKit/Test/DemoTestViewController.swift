//
//  DemoTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/9.
//

import UIKit

class DemoTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let randomColor: () -> UIColor = {
            let color = UIColor(hue: CGFloat.random(in: 0...1), saturation: CGFloat.random(in: 0...1), brightness: CGFloat.random(in: 0...1), alpha: 1)
            return color
        }

        self.view.arrangeViews {
            UIScrollView(.vertical) {
                for row in 0..<10 {
                    UIView {
                        UIStackView(axis: .horizontal, alignment: .center, spacing: 10) {
                            UIView()
                                .backgroundColor(randomColor())
                                .cornerRadius(4)
                                .frame(width: 40, height: 40)

                            UIStackView(axis: .vertical, alignment: .leading) {
                                UILabel().text("Title text \(row)")
                                    .textColor(randomColor())
                                    .font(.systemFont(ofSize: 17, weight: .semibold))
                                UILabel().text("Detail text Detail text Detail text \(row)")
                                    .textColor(randomColor())
                                    .font(.systemFont(ofSize: 14, weight: .regular))
                            }
                        }
                        .alignment([.leading, .centerY])
                        .margin(leading: 12)

                        UIView()
                            .backgroundColor(.lightGray)
                            .frame(height: 0.5)
                            .alignment([.leading, .bottom, .trailing])
                            .margin(leading: 12)
                    }
                    .frame(height: 60)
                }
            }
            .alignment(.allEdges)
            .bounce(.vertical)
        }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
