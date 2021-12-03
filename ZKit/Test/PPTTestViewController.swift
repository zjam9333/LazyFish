//
//  PPTTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/12/2.
//

import UIKit

class PPTTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let title = "姓名"
        let summary = "摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要摘要"
        self.view.arrangeViews {
            UIView {
                UIStackView(axis: .horizontal, alignment: .top, spacing: 16) {
                    UIView().backgroundColor(.white)
                        .frame(width: 64, height: 64)
                        .cornerRadius(32)
                    UIStackView(axis: .vertical, spacing: 12) {
                        UILabel(title)
                            .font(.systemFont(ofSize: 20, weight: .bold))
                        UILabel(summary)
                            .font(.systemFont(ofSize: 16, weight: .regular)).numberOfLines(0)
                    }
                }
                .padding(16).alignment(.allEdges)
            }
            .cornerRadius(20)
            .backgroundColor(.init(white: 0.9, alpha: 1))
            .padding(top: 100)
            .alignment([.top, .leading], value: 16)
            .alignment(.trailing, value: -64)
        }
        // Do any additional setup after loading the view.
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
