//
//  StateTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/20.
//

import UIKit

class StateTestViewController: UIViewController {
    
    @ZKit.State var showCake: Bool = true
    @ZKit.State var showAnimals: Bool = true
    @ZKit.State var addNum: Int = 0
    @ZKit.State var sayWhat: String = "Hello"
    
    let animalNames: [String] = [
        "Dog 🐶", "Cat 🐯", "Pig 🐷"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.arrangeViews {
            UIStackView(axis: .vertical, alignment: .center) {
                foodForTitle("Tea 🍵")
                IfBlock(_showCake) {
                    foodForTitle("Cake 🍰")
                        .borderColor(.blue).borderWidth(1)
                }
                foodForTitle("Pizza 🍕")
                
                IfBlock(_showAnimals) {
                    for i in animalNames {
                        foodForTitle(i)
                            .borderColor(.lightGray).borderWidth(1)
                    }
                }
                
                UIStackView(axis: .horizontal) {
                    UILabel().text("label with bool state: ")
                    IfBlock(_addNum) { i in
                        i % 2 == 0
                    } contentIf: {
                        foodForTitle("Hello!")
                            .borderColor(.red).borderWidth(1)
                    } contentElse: {
                        foodForTitle("World!")
                            .borderColor(.blue).borderWidth(1)
                    }
                }
                
                UIStackView(axis: .horizontal) {
                    UILabel().text("text with string state: ")
                    UILabel().text(_sayWhat).font(.systemFont(ofSize: 30, weight: .black)).textColor(.brown)
                }
            }.alignment(.center)
            
            UIStackView(axis: .vertical) {
                buttonForTitle("Toggle Cake 🍰") { [weak self] in
                    self?.showCake.toggle()
                }
                buttonForTitle("Toggle Animals 🙊") { [weak self] in
                    self?.showAnimals.toggle()
                }
                buttonForTitle(_sayWhat) { [weak self] in
                    self?.addNum += 1
                    if self?.sayWhat == "Hello" {
                        self?.sayWhat = "World"
                    } else {
                        self?.sayWhat = "Hello"
                    }
                }
            }
            .alignment([.bottom, .centerX]).padding(bottom: 60)
        }
    }
    
    func foodForTitle(_ str: String) -> UILabel {
        UILabel().text(str).textColor(.black).font(.systemFont(ofSize: 30, weight: .black)).alignment(.center)
    }
    
    func buttonForTitle(_ str: String, action: @escaping () -> Void) -> UIButton {
        UIButton().text(str).font(.systemFont(ofSize: 20, weight: .black))
            .textColor(.black)
            .textColor(.gray, for: .highlighted)
            .action {
                action()
            }
    }
    
    func buttonForTitle(_ str: ZKit.State<String>, action: @escaping () -> Void) -> UIButton {
        UIButton().text(str).font(.systemFont(ofSize: 20, weight: .black))
            .textColor(.black)
            .textColor(.gray, for: .highlighted)
            .action {
                action()
            }
    }
}
