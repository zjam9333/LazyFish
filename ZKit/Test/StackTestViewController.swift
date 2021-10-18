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
            
            var centerViews = [UIView]()
            let colors: [UIColor] = [.brown, .black, .blue]
            UIStackView(axis: .horizontal, spacing: 8) {
                for i in 0...2 {
                    let view = UIButton().text("\(i)").textAlignment(.center).textColor(.white)
                    .backgroundColor(colors[i])
                        .frame(width: 40, height: 40)
                        .action(for: .touchDown) {
                            print(i)
                        }
                        //.margin(top: 10, leading: 10, bottom: 10, trailing: 10)
                    if i == 0 {
                        view.offset(x: -15, y: -88)
                    } else {
                        view
                    }
                    centerViews.append(view)
                }
            }.padding(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            UIStackView(axis: .vertical) {
                for i in 0...2 {
                    let but = UIButton()
                    but.setTitle("toggle hide center rect \(i)", for: .normal)
                    but.setTitleColor(.brown, for: .normal)
                    but.setTitleColor(.green, for: .highlighted)
                    but.backgroundColor = .yellow
                    but.action {
                        centerViews[i].isHidden.toggle()
                    }
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
