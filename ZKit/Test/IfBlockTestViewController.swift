//
//  IfBlockTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/20.
//

import UIKit

class IfBlockTestViewController: UIViewController {
    
    @ZKit.State var showCake: Bool = false
    @ZKit.State var showAnimals: Bool = true
    
    let animalNames: [String] = [
        "Dog 🐶", "Cat 🐯", "Pig 🐷"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.arrangeViews {
            UIStackView(axis: .vertical) {
                foodForTitle("Tea 🍵")
                IfBlock(_showCake) {
                    foodForTitle("Cake 🍰")
                }
                foodForTitle("Pizza 🍕")
                
                IfBlock(_showAnimals) {
                    for i in animalNames {
                        foodForTitle(i)
                    }
                }
            }.alignment(.center)
            
            UIStackView(axis: .vertical) {
                buttonForTitle("Toggle Cake 🍰") { [weak self] in
                    self?.showCake.toggle()
                }
                buttonForTitle("Toggle Animals 🙊") { [weak self] in
                    self?.showAnimals.toggle()
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
}
