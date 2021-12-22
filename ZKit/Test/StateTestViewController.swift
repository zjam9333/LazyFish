//
//  StateTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/20.
//

import UIKit
import ZKitCore

class StateTestViewController: UIViewController {
    
    @State var showCake: Bool = true
    @State var showAnimals: Bool = true
    @State var addNum: Int = 0
    @State var sayWhat: String = "Hello"
    
    let animalNames: [String] = [
        "Dog 🐶", "Cat 🐯", "Pig 🐷"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let foodForTitle: (String) -> UILabel = { str in
            UILabel().text(str).textColor(.black).font(.systemFont(ofSize: 30, weight: .black)).alignment(.center)
        }
        let buttonForTitle: (String, @escaping () -> Void) -> UIButton = { str, action in
            UIButton().text(str).font(.systemFont(ofSize: 20, weight: .black))
                .textColor(.black)
                .textColor(.gray, for: .highlighted)
                .action {
                    action()
                }
        }
        let buttonForTitleBinding: (Binding<String>?, @escaping () -> Void) -> UIButton = { str, action in
            UIButton().text(binding: str).font(.systemFont(ofSize: 20, weight: .black))
                .textColor(.black)
                .textColor(.gray, for: .highlighted)
                .action {
                    action()
                }
        }
        
        view.arrangeViews {
            
            UIStackView(axis: .vertical, alignment: .center, spacing: 10) {
                foodForTitle("Tea 🍵")
                IfBlock($showCake) {
                    foodForTitle("Cake 🍰")
                        .borderColor(.blue).borderWidth(1)
                } contentElse: {
                    foodForTitle("NO !!Cake 🍰")
                        .borderColor(.yellow).borderWidth(1)
                    IfBlock($showAnimals) {
                        foodForTitle("But animals")
                            .borderColor(.yellow).borderWidth(1)
                    }
                }
                foodForTitle("Pizza 🍕")
                
                IfBlock($showAnimals) {
                    for i in animalNames {
                        foodForTitle(i)
                            .borderColor(.lightGray).borderWidth(1)
                    }
                }
                
                UIStackView(axis: .horizontal) {
                    UILabel().text("label with bool state: ")
                    let numberMap = $addNum.map { i in
                        i % 2 == 0
                    }
                    IfBlock(numberMap) {
                        foodForTitle("Hello!")
                            .borderColor(.red).borderWidth(1)
                    } contentElse: {
                        foodForTitle("World!")
                            .borderColor(.blue).borderWidth(1)
                    }
                }
                
                UIStackView(axis: .horizontal) {
                    UILabel().text("text with string state: ")
                    UILabel().text(binding: $sayWhat).font(.systemFont(ofSize: 30, weight: .black)).textColor(.brown)
                }
            }.alignment(.center)
            
            UIStackView(axis: .vertical) {
                buttonForTitle("Toggle Cake 🍰") { [weak self] in
                    self?.showCake.toggle()
                }
                buttonForTitle("Toggle Animals 🙊") { [weak self] in
                    self?.showAnimals.toggle()
                }
                buttonForTitleBinding($sayWhat) { [weak self] in
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
    
    
}
