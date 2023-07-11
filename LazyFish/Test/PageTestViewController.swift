//
//  PageTestViewController.swift
//  LazyFish
//
//  Created by zjj on 2021/10/26.
//

import UIKit
import LazyFishCore

class PageTestViewController: UIViewController {

    @State var pages = (0..<5).map { i in
        "page\(i)"
    }
    @State var currentPage: CGFloat = 0
    @State var showPage1: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.arrangeViews {
            UIStackView(axis: .vertical, alignment: .center, spacing: 10) {
                GeometryReader { geo in
                    UIScrollView(.horizontal) {
                        ForEachEnumerated($pages) { i, name in
                            UILabel()
                                .text(name)
                                .textAlignment(.center)
                                .textColor(.black)
                                .border(width: 1, color: .black)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .backgroundColor(UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1))
                                .propertyModifing { lab in
                                    if i == 1 {
                                        _ = lab.border(width: 3, color: .red).backgroundColor(.yellow).property(\.isHidden, binding: self.$showPage1 != true)
                                    }
                                }
                        }
                    }
                    .frame(width: 240, height: 240)
                    .pageEnabled(true)
                    .pageObserve { [weak self] page in
                        self?.currentPage = page
    //                    print(page)
                    }
                }
                
                // page control
                let ballWidth: CGFloat = 4
                UIStackView(axis: .horizontal, spacing: ballWidth) {
                    ForEach($pages) { [weak self] i in
                        IfBlock(self?.$currentPage.map { [weak self] currentPage in
                            return Int(currentPage + 0.5) == self?.pages.firstIndex(of: i) ?? 0
                        }) {
                            UIView().backgroundColor(UIColor(white: 0.7, alpha: 1)).frame(width: ballWidth * 2, height: ballWidth)
                                .cornerRadius(ballWidth / 2)
                        } contentElse: {
                            UIView().backgroundColor(UIColor(white: 0.9, alpha: 1)).frame(width: ballWidth, height: ballWidth)
                                .cornerRadius(ballWidth / 2)
                        }
                    }
                }
                
                UIButton()
                    .textColor(.black)
                    .font(.systemFont(ofSize: 17, weight: .bold))
                    .onAction(forEvent: .touchUpInside) { [weak self] b in
                        ActionWithAnimation {
                            self?.showPage1.toggle()
                        }
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
