//
//  NewBindingTestViewController.swift
//  LazyFishTest
//
//  Created by zjj on 2023/8/15.
//

import UIKit
import LazyFishCore

class NewBindingTestViewController: UIViewController {
    
    struct TestModelStruct {
        var foo1 = true;
        var foo2 = 1;
        var foo3 = "ABCD";
        var foo4 = 1.9999
    }
    
    @State var testModel = TestModelStruct()
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bind2 = Binding(wrapper: _testModel, currentValue: self.testModel).foo4 + 123123 - 123
        let bind3 = Binding(wrapper: _testModel, currentValue: self.testModel).foo3
        let bind4 = bind2.join(bind3)
        let bind = bind2.join(bind3) { a, b in
            return "\(a) + \(b)"
        }
        bind.addObserver(target: self) { [weak self] changed in
            self?.label.text = "\(changed.new)"
        }
        view.arrangeViews {
            
            UIStackView(axis: .vertical) {
                label
                UIButton("OK")
                    .textColor(.systemBlue)
                    .onAction { [weak self] b in
                        self?.testModel.foo3 = String(UUID().uuidString.prefix(4))
                    }
                UISwitch()
                    .isOn(binding: $testModel.foo1) { [weak self] fi in
                        self?.testModel.foo1 = fi
                    }
            }
            .alignment(.center, value: 0)
            .frame(width: 300)
        }
    }
    
}
