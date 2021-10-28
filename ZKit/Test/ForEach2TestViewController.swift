//
//  ForEach2TestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/28.
//

import UIKit
import ZKitCore

// TODO: - Did Not Passed

class ForEach2TestViewController: UIViewController {
    let animals = ["bird", "dog", "cat", "horse", "bull", "goat", "fish"]
    @State var section1: [String] = ["bird"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.arrangeViews {
            UIScrollView (.vertical, spacing: 0) {
                // section 1
                UILabel().text("Header").backgroundColor(.lightGray)
                
                ForEach($section1) { str in
                    UILabel().text(str).alignment(.allEdges).backgroundColor(.yellow)
                }
                .border(width: 1, color: .red)
            }
            .alignment([.leading], value: 60)
            .alignment(.centerX)
            .frame(height: 300)
            .bounce(.vertical)
            
            UIStackView(axis: .horizontal, alignment: .fill, spacing: 10) {
                UIStackView(axis: .horizontal) {
                    UIButton().text("-").textColor(.black).action { [weak self] in
                        if self?.section1.isEmpty == false {
                            self?.section1.removeFirst()
                        }
                    }
                    UILabel().text("section1").textColor(.black)
                    UIButton().text("+").textColor(.black).action { [weak self] in
                        if let ran = self?.animals.randomElement() {
                            self?.section1.append(ran)
                        }
                    }
                }
            }
            .alignment(.centerX)
            .alignment(.bottom, value: -60)
            .border(width: 1, color: .black)
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
