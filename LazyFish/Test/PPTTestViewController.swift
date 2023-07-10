//
//  PPTTestViewController.swift
//  LazyFish
//
//  Created by zjj on 2021/12/2.
//

import UIKit

class PPTTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.arrangeViews {
            UIScrollView(.vertical, spacing: 12) {
                UIStackView(axis: .horizontal, alignment: .top, spacing: 16) {
                    UIView().backgroundColor(.white)
                        .frame(width: 64, height: 64)
                        .cornerRadius(32)
                    UIStackView(axis: .vertical, spacing: 12) {
                        UILabel("姓名：杨过")
                            .font(.systemFont(ofSize: 20, weight: .bold))
                        UILabel("年龄：18")
                            .font(.systemFont(ofSize: 16, weight: .regular))
                        UILabel("流派：武当")
                            .font(.systemFont(ofSize: 16, weight: .regular))
                    }
                }
                .padding(16).alignment(.allEdges)
                .cornerRadius(6)
                .backgroundColor(.init(white: 0.9, alpha: 1))
                
                UIStackView(axis: .vertical, spacing: 16) {
                    UILabel("详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明")
                        .font(.systemFont(ofSize: 16, weight: .regular))
                        .numberOfLines(0)
                }
                .padding(16).alignment(.allEdges)
                .cornerRadius(6)
                .backgroundColor(.init(white: 0.9, alpha: 1))
            }
            .alignment(.allEdges)
            .bounce(.vertical)
            .padding(20)
//            .alignment(.center).alignment(.leading, value: 10)
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
