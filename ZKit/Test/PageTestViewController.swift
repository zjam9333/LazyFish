//
//  PageTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/26.
//

import UIKit
import ZKitCore

class PageTestViewController: UIViewController {

    @State var pages = Array(0..<5)
    @State var currentPage: CGFloat = 0
    @State var showPage1: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.arrangeViews {
            UIStackView(axis: .vertical, alignment: .center, spacing: 10) {
                UIScrollView(.horizontal) {
                    ForEach($pages) { [weak self] i in
                        let lab = UILabel()
                            .text("page: \(i)")
                            .textAlignment(.center)
                            .textColor(.black)
                            .border(width: 1, color: .black)
                            .frame(width: .fillParent())
                            .backgroundColor(UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1))
//                        lab
                        if i == 2 {
                            IfBlock(self?.$showPage1) {
                                lab.border(width: 3, color: .red).backgroundColor(.yellow)
                            }
                        } else {
                            lab
                        }
                    }
                }
                .frame(width: 240, height: 240)
                .pageEnabled(true)
                .pageObserve { [weak self] page in
                    self?.currentPage = page
//                    print(page)
                }
                
                // page control
                let ballWidth: CGFloat = 4
                UIStackView(axis: .horizontal, spacing: ballWidth) {
                    ForEach($pages) { [weak self] i in
                        IfBlock(self?.$currentPage) { currentPage in
//                    for i in 0..<pageCount {
//                        IfBlock($currentPage) { currentPage in
                            return Int(currentPage + 0.5) == i
                        } contentIf: {
                            UIView().backgroundColor(UIColor(white: 0.7, alpha: 1)).frame(width: ballWidth * 2, height: ballWidth)
                                .cornerRadius(ballWidth / 2)
                        } contentElse: {
                            UIView().backgroundColor(UIColor(white: 0.9, alpha: 1)).frame(width: ballWidth, height: ballWidth)
                                .cornerRadius(ballWidth / 2)
                        }
                    }
                }
                
                UIButton()
                    .textColor(.black).font(.systemFont(ofSize: 17, weight: .bold))
                    .action(for: .touchUpInside) { [weak self] in
                        self?.showPage1.toggle()
                    }
                    .text("toggle page 2")
            }
            .alignment([.top, .leading], value: 100)
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
