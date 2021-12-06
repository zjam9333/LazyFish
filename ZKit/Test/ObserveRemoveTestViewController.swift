//
//  ObserveRemoveTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/12/3.
//

import UIKit
import ZKitCore

class ObserveRemoveTestViewController: UIViewController {

    @State var objects: [Int] = [1, 2, 3, 4, 5]
    @State var random: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.arrangeViews {
            UIStackView(axis: .vertical, spacing: 5) {
                UILabel("Check the @State observers count after refresh Objects")
                    .numberOfLines(0)
                ForEachEnumerated($objects) { [weak self] index, _ in
//                    UIStackView(axis: .horizontal, alignment: .center, spacing: 5) {
//                        UILabel("Title \(index)")
                        IfBlock(self?.$random) { v in
                            index >= v
                        } contentIf: {
                            UILabel("Title \(index)").backgroundColor(.red)
                        } contentElse: {
                            UILabel("Title \(index)").backgroundColor(.gray)
                        }
//                    }
                }
                UIButton("Change Random").textColor(.blue).action { [weak self] in
                    if self?.random ?? 0 >= 5 {
                        self?.random = 0
                    } else {
                        self?.random += 1
                    }
                }
                UIButton("Change Objects").textColor(.red).action { [weak self] in
                    if self?.objects.count ?? 0 >= 5 {
                        self?.objects = [1]
                    } else {
                        self?.objects.append(1)
                    }
                }
            }
            .frame(width: 200)
            .alignment(.bottom, value: -64)
            .alignment(.centerX)
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
