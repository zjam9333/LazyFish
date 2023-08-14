//
//  ObservableObjectTestViewController.swift
//  LazyFishTest
//
//  Created by zjj on 2023/8/14.
//

import UIKit
import LazyFishCore

class ObservableObjectTestViewController: UIViewController {
    class TestModelClass: StateObject {
        @StateProperty var foo1 = true;
        @StateProperty var foo2 = 1;
        @StateProperty var foo3 = "ABCD";
        var foo4 = 1.9999
    }
    
    struct TestModelStruct {
        var foo1 = true;
        var foo2 = 1;
        var foo3 = "ABCD";
        var foo4 = 1.9999
    }
    
    @State var testModel = TestModelStruct()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.arrangeViews {
            let bind = $testModel.foo3.join($testModel.foo1) { str, boo in
                return "\(str) + \(boo)"
            }.join($testModel.foo4) { str, boo in
                return "\(str) + \(boo)"
            }
            UIStackView(axis: .vertical) {
                UILabel().text(binding: bind)
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
