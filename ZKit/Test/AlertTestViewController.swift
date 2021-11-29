//
//  Test2ViewController.swift
//  ZKit
//
//  Created by zjj on 2021/10/8.
//

import UIKit
import ZKitCore

fileprivate enum AlertStyle {
    case `default`
    case cancel
    var color: UIColor {
        switch self {
        case .cancel:
            return .black
        case .default:
            return .systemBlue
        }
    }
    var font: UIFont {
        switch self {
        case .cancel:
            return .systemFont(ofSize: 14, weight: .regular)
        case .default:
            return .systemFont(ofSize: 14, weight: .semibold)
        }
    }
}

fileprivate struct AlertAction {
    let name: String
    let style: AlertStyle
    let action: () -> Void
}
fileprivate typealias AlertActionBuilder = ResultBuilder<AlertAction>

fileprivate class TestAlertView: UIView {
    
    let alertActions: [AlertAction]
    let title: String
    let message: String
    init(title: String, message: String, @AlertActionBuilder actions: () -> [AlertAction]) {
        self.title = title
        self.message = message
        alertActions = actions()
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var alertContent: UIView? = UIView("center Card") {
        
        let hideAlert = { [weak self] in
            UIView.animate(withDuration: 0.25) {
                self?.alpha = 0
                self?.alertContent?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            } completion: { fi in
                self?.removeFromSuperview()
            }
        }
        
        //
        UIStackView(axis: .vertical, distribution: .fill, alignment: .fill, spacing: 0) {
            UIStackView(axis: .vertical, distribution: .fill, alignment: .leading, spacing: 12) {
                UILabel()
                    .text(title)
                    .textColor(.black)
                    .font(UIFont.systemFont(ofSize: 16, weight: .bold))
                
                UILabel()
                    .text(message)
                    .textColor(.darkGray)
                    .font(UIFont.systemFont(ofSize: 14, weight: .regular))
            }
            .alignment(.allEdges)
            .padding(top: 20, leading: 20, bottom: 20, trailing: 20)
            
            UIView()
                .backgroundColor(.lightGray)
                .frame(height: 0.5)
            
            UIStackView(axis: .horizontal, distribution: .fillEqually, alignment: .fill, spacing: 0) {
                for i in alertActions {
                    UIButton()
                        .text(i.name)
                        .textColor(i.style.color, for: .normal)
                        .textColor(i.style.color.withAlphaComponent(0.5), for: .highlighted)
                        .font(i.style.font)
                        .action {
                            hideAlert()
                            i.action()
                        }
                }
            }.frame(height: 48)
        }
        .alignment(.allEdges)
    }
    .backgroundColor(.white)
    .cornerRadius(10).clipped()
    .frame(width: 300)
    .alignment(.center)
    .onAppear { [weak self] someview in
        print("apppp")
        self?.alpha = 0
        self?.alertContent?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.25) {
            self?.alpha = 1
            self?.alertContent?.transform = CGAffineTransform.identity
        }
    }
    
    deinit {
        print("deinit alert")
    }

    func testShow() {
        let mySelfAlert = self.arrangeViews {
            self.alertContent
        }
        .alignment(.allEdges)
        .backgroundColor(.black.withAlphaComponent(0.3))
        UIApplication.shared.keyWindow?.arrangeViews {
            mySelfAlert
        }
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
                .padding(top: 10, leading: 10, bottom: 10, trailing: 10)
                .backgroundColor(.gray)
                .alignment(.center)
                .action {
                    TestAlertView(title: "Logout", message: "Are you sure?") {
                        AlertAction(name: "Cancel", style: .cancel) {
                            print("cancelled")
                        }
                        AlertAction(name: "OK", style: .default) {
                            print("comfirmed")
                        }
                    }.testShow()
                }
        }
        // Do any additional setup after loading the view.
    }
}
