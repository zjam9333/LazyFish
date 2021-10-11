//
//  Test1ViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import UIKit

class StackTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stackView = UIStackView(axis: .horizontal, alignment: .top) {
            let lab = UILabel()
            lab.text = "LIne1"
            lab.textColor = .red
            lab.backgroundColor = .green
            lab.frame(width: 100, height: 64)

            lab
            
            let view = UIView()
            view.backgroundColor = .black
            view.frame(width: 2, height: 18)
            
            UIStackView(axis: .vertical) {
                for i in 0...2 {
                    let but = UIButton()
                    but.setTitle("button\(i)", for: .normal)
                    but.setTitleColor(.brown, for: .normal)
                    but.setTitleColor(.green, for: .highlighted)
                    but.backgroundColor = .yellow
                    but
                }
                
                if Bool.random() {
                    let lab = UILabel()
                    lab.text = "random1"
                    lab.textColor = .green
                    lab.backgroundColor = .red
                    lab
                } else {
                    let lab = UILabel()
                    lab.text = "random not 1"
                    lab.textColor = .red
                    lab.backgroundColor = .green
                    lab
                }
                
                let lab = UILabel()
                lab.text = "Line2"
                lab.textColor = .green
                lab.backgroundColor = .blue
                lab
                
                let lab = UILabel()
                lab.text = "Line3"
                lab.textColor = .blue
                lab.backgroundColor = .red
                lab
                
                UIStackView(axis: .horizontal, spacing: 10) {
                    for i in 0...2 {
                        let lab = UILabel()
                        lab.text = "Li\(i)"
                        lab.numberOfLines = 0
                        lab.textColor = .blue
                        lab.backgroundColor = .red
                        lab
                    }
                }
            }
        }
        
        self.view.arrangeViews {
            stackView.alignment(.center)
        }
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
