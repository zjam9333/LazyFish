//
//  ForEachTestViewController.swift
//  LazyFish
//
//  Created by zjj on 2021/10/28.
//

import UIKit
import LazyFishCore

class ForEachTestViewController: UIViewController {
    let animals = ["bird", "dog", "cat", "horse", "bull", "goat", "fish"]
    let colors = ["red", "green", "blue", "black", "gray", "brown", "yellow"]
    @State var section1: [String] = ["bird"]
    @State var section2: [String] = ["green"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.arrangeViews {
            UIStackView(axis: .vertical, spacing: 10) {
                UIStackView(axis: .horizontal, spacing: 10) {
                    // section 1
                    UILabel().text("Header").backgroundColor(.lightGray)
                    
                    ForEach($section1) { str in
                        UILabel().text(str).backgroundColor(.yellow)
                    }
                    .border(width: 1, color: .red)
                    
                    UILabel().text("Footer").backgroundColor(.lightGray)
                }
                
                
                // section 2
                UILabel().text("Header2").backgroundColor(.lightGray)
                
                ForEach($section2) { str in
                    UILabel().text(str).backgroundColor(.cyan)
                }.border(width: 1, color: .green)
                
                UILabel().text("Footer2").backgroundColor(.lightGray)
            }.alignment(.center)
            
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
                
                UIStackView(axis: .horizontal) {
                    UIButton().text("-").textColor(.black).action { [weak self] in
                        if self?.section2.isEmpty == false {
                            self?.section2.removeFirst()
                        }
                    }
                    UILabel().text("section2").textColor(.black)
                    UIButton().text("+").textColor(.black).action { [weak self] in
                        if let ran = self?.colors.randomElement() {
                            self?.section2.append(ran)
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
