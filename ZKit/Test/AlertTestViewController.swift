//
//  Test2ViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import UIKit

fileprivate class TestAlertView: UIView {
    
    var alertView: UIView? = nil
    var alertContent: UIView? = nil
    
    deinit {
        print("deinit", self)
    }

    func testShow() -> Self? {
        let hideAlert = { [weak self] in
            UIView.animate(withDuration: 0.25) {
                self?.alertView?.alpha = 0
                self?.alertContent?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            } completion: { fi in
                self?.removeFromSuperview()
            }
        }
        
        self.alertView = UIView("main BG") { [weak self] in
            self?.alertContent = UIView("center Card") {
                UIStackView(axis: .vertical, distribution: .fill, alignment: .fill, spacing: 0) {
                    UIStackView(axis: .vertical, distribution: .fill, alignment: .leading, spacing: 12) {
                        UILabel()
                            .text("退出登录")
                            .textColor(.black)
                            .font(UIFont.systemFont(ofSize: 16, weight: .bold))
                        
                        UILabel()
                            .text("确定要退出登录吗？")
                            .textColor(.darkGray)
                            .font(UIFont.systemFont(ofSize: 14, weight: .regular))
                    }
                    .frame(alignment: .allEdges)
                    .margin(top: 20, leading: 20, bottom: 20, trailing: 20)
                    
                    UIView()
                        .backgroundColor(.lightGray)
                        .frame(height: 0.5)
                    
                    UIStackView(axis: .horizontal, distribution: .fillEqually, alignment: .fill, spacing: 0) {
                        UIButton()
                            .text("取消")
                            .textColor(.black, for: .normal)
                            .textColor(.black.withAlphaComponent(0.5), for: .highlighted)
                            .font(UIFont.systemFont(ofSize: 14, weight: .regular))
                            .action {
                                print("取消")
                                hideAlert()
                            }
                        
                        UIButton()
                            .text("确认")
                            .textColor(.systemBlue, for: .normal)
                            .textColor(.systemBlue, for: .normal)
                            .font(UIFont.systemFont(ofSize: 14, weight: .semibold))
                            .action {
                                print("确认")
                                hideAlert()
                            }
                    }.frame(height: 48)
                }
                .frame(alignment: .allEdges)
            }
            .backgroundColor(.white)
            .cornerRadius(10).clipped()
            .frame(width: 300, alignment: .center)
            .onAppear { [weak self] in
                print("apppp")
                self?.alertView?.alpha = 0
                self?.alertContent?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                UIView.animate(withDuration: 0.25) {
                    self?.alertView?.alpha = 1
                    self?.alertContent?.transform = CGAffineTransform.identity
                }
            }
            self?.alertContent
        }
        .frame(alignment: .allEdges)
        .backgroundColor(.gray)
        
        self.arrangeViews {
            self.alertView?.frame(alignment: .allEdges)
        }
        return self.frame(alignment: .allEdges)
    }
}

class AlertTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.arrangeViews {
            UIButton()
                .text("Show an Alert", for: .normal)
                .textColor(.black)
                .font(UIFont.systemFont(ofSize: 28, weight: .black))
                .margin(top: 10, leading: 10, bottom: 10, trailing: 10)
                .backgroundColor(.gray)
                .frame(alignment: .center)
                .action { [weak self] in
                    
                self?.view.arrangeViews {
                    TestAlertView().testShow()
                }
            }
        }
        // Do any additional setup after loading the view.
    }
}
