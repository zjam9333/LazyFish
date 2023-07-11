//
//  ForEach2TestViewController.swift
//  LazyFish
//
//  Created by zjj on 2021/10/28.
//

import UIKit
import LazyFishCore

class ForEachScrollTestViewController: UIViewController {
    let animals = ["bird", "dog", "cat", "horse", "bull", "goat", "fish"]
    @State var showBirds = true
    @State var section1: [String] = ["bird"]
    
    deinit {
        print("deinit", self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.arrangeViews { [weak self] in
            GeometryReader { [weak self] geo in
                UIScrollView (.vertical, spacing: 10) {
                    // section 1
                    UILabel().text("Header").backgroundColor(.lightGray)
                    
                    ForEach(self?.$section1) { str in
                        if str == "bird" {
                            IfBlock(self?.$showBirds) {
                                UILabel().text(str).backgroundColor(.cyan)
                            }
                        } else {
                        UILabel().text(str).backgroundColor(.yellow)
                        }
                    }
                    .border(width: 1, color: .red)
                    
                    UILabel().text("Footer").backgroundColor(.lightGray)
                }
                .alignment([.top], value: 60)
                .alignment(.centerX)
                .frame(width: geo.size.width * 0.5, height: geo.size.height)
                .bounce(.vertical)
            }
            
            UIStackView(axis: .horizontal, alignment: .fill, spacing: 10) {
                UIStackView(axis: .horizontal) {
                    UIButton().text("-").textColor(.black).onAction { [weak self] b in
                        if self?.section1.isEmpty == false {
                            self?.section1.removeFirst()
                        }
                    }
                    UILabel().text("section1").textColor(.black)
                    UIButton().text("+").textColor(.black).onAction { [weak self] b in
                        if let ran = self?.animals.randomElement() {
                            self?.section1.append(ran)
                        }
                    }
                    UIButton().text("toggleBirds").textColor(.red).font(.systemFont(ofSize: 20, weight: .bold)).onAction { [weak self] b in
                        self?.showBirds.toggle()
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
