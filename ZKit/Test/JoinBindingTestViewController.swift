//
//  JoinBindingTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/12/16.
//

import UIKit
import ZKitCore

class JoinBindingTestViewController: UIViewController {

    @State var text1: String = "cde"
    @State var text2: String = "fgab"
    @State var number3: String = "100"

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let colorJo = $text1.join($text2).join($number3).map { i -> String in
//            let ((s1, s2), n1) = i
//            let s = s1 + "_" + s2 + "_\(n1)"
//            return s
//        }
        view.arrangeViews {
            UIView() {
                UIStackView(axis: .vertical, spacing: 10) {
                    UILabel().text("joined input result:")
                        .setKeyPath(\.textColor, value: .blue)
                        .padding(10)
                        .setKeyPath(\.backgroundColor, value: .lightGray)
                        .setKeyPath(\.layer.borderColor, value: UIColor.black.cgColor)
                        .setKeyPath(\.layer.borderWidth, value: 2)
                    UILabel().text("text1 is Empty?")
                        .bindingKeyPath(\.textColor, with: $text1.map({ s in
                            s.isEmpty ? .red : .green
                        }))
                    
                    // 这里的label.text是optional的，但编译器却允许传入binding<String> ？？
                    UILabel()
                        .bindingKeyPath(\.text, with: $text1.join($text2).join($number3).map { i -> String in
                            let ((s1, s2), n1) = i
                            let s = s1 + "_" + s2 + "_\(n1)"
                            return s
                        })
                        .numberOfLines(0)
                        .border(width: 1, color: .black)
                    UITextField().text(binding: $text1, changed: { [weak self] t in
                        self?.text1 = t
                    }).borderStyle(.roundedRect)
                    UITextField().text(binding: $text2, changed: { [weak self] t in
                        self?.text2 = t
                    }).borderStyle(.roundedRect)
                    UITextField().text(binding: $number3, changed: { [weak self] t in
                        self?.number3 = t
                    }).borderStyle(.roundedRect)
                }
                .padding(top: 10, leading: 10, bottom: 10, trailing: 10)
                .alignment(.allEdges)
            }
            .borderWidth(1)
            .borderColor(.black)
            .frame(width: 300)
            .alignment(.top, value: 160)
            .alignment(.centerX, value: 0)
        }
        // Do any additional setup after loading the view.
    }
}
