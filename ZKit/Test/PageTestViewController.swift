//
//  PageTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/26.
//

import UIKit
import ZKitCore

class PageTestViewController: UIViewController {

    let pageCount = 5
    @State var currentPage: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.arrangeViews {
            UIStackView(axis: .vertical, alignment: .center, spacing: 10) {
                UIScrollView(.horizontal) {
                    for i in 0..<pageCount {
                        UILabel()
                            .text("page: \(i)")
                            .textAlignment(.center)
                            .textColor(.black)
                            .border(width: 1, color: .black)
                            .frame(width: .fillParent)
                            .backgroundColor(UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1))
                    }
                }
                .frame(width: 240, height: 240)
                .pageEnabled(true)
                .pageObserve { [weak self] page in
                    self?.currentPage = page
//                    print(page)
                }
                
                UIStackView(axis: .horizontal, spacing: 4) {
                    for i in 0..<pageCount {
                        IfBlock($currentPage) { currentPage in
                            return Int(currentPage + 0.5) == i
                        } contentIf: {
                            UIView().backgroundColor(UIColor(white: 0.7, alpha: 1)).frame(width: 12, height: 8)
                                .cornerRadius(4)
                        } contentElse: {
                            UIView().backgroundColor(UIColor(white: 0.9, alpha: 1)).frame(width: 8, height: 8)
                                .cornerRadius(4)
                        }
                    }
                }
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
