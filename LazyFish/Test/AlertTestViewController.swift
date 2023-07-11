//
//  Test2ViewController.swift
//  LazyFish
//
//  Created by zjj on 2021/10/8.
//

import UIKit
import LazyFishCore

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

fileprivate typealias AlertActionBuilder = ArrayBuilder<AlertAction>

fileprivate class AlertView: UIView {
    
    let alertActions: [AlertAction]
    let title: String
    let message: String
    
    @State var alertAlpha: CGFloat = 0
    @State var alertScale: CGFloat = 0.1
    
    @discardableResult init(showInView view: UIView?,title: String, message: String, @AlertActionBuilder actions: () -> [AlertAction]) {
        self.title = title
        self.message = message
        self.alertActions = actions()
        super.init(frame: .zero)
        view?.arrangeViews {
            self.arrangeViews { // self作为背景
                UIView { // 中间的内容
                    UIStackView(axis: .vertical, distribution: .fill, alignment: .fill, spacing: 0) {
                        UIStackView(axis: .vertical, distribution: .fill, alignment: .leading, spacing: 12) {
                            UILabel()
                                .text(title)
                                .textColor(.black)
                                .font(UIFont.systemFont(ofSize: 16, weight: .bold))
                            
                            UILabel()
                                .text(message)
                                .numberOfLines(0)
                                .textColor(.darkGray)
                                .font(UIFont.systemFont(ofSize: 14, weight: .regular))
                        }
                        .padding(20)
                        
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
                                    .onAction { [weak self] b in
                                        i.action()
                                        ActionWithAnimation(.default) {
                                            self?.alertScale = 0.1
                                            self?.alertAlpha = 0
                                        } completion: { fi in
                                            self?.removeFromSuperview()
                                        }
                                    }
                            }
                        }.frame(height: 48)
                    }
                }
                .backgroundColor(.white)
                .cornerRadius(5).clipped()
                .frame(width: 300)
                .alignment(.center)
                .property(\.transform, binding: $alertScale.map {
                    scale -> CGAffineTransform in
                    return .identity.scaledBy(x: scale, y: scale)
                })
                .property(\.alpha, binding: $alertAlpha)
                .onAppear { [weak self] someview in
                    ActionWithAnimation(.default) {
                        self?.alertScale = 1
                        self?.alertAlpha = 1
                    } completion: { fi in
                        print("fi")
                    }
                }
            }
            .property(\.alpha, binding: $alertAlpha)
            .backgroundColor(.black.withAlphaComponent(0.3))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AlertTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.arrangeViews {
            UIButton()
                .text("Show an Alert", for: .normal)
                .textColor(.black)
                .font(UIFont.systemFont(ofSize: 28, weight: .black))
                .onAction { [weak self] b in
                    AlertView(showInView: self?.view, title: "Logout", message: "Are you sure? Are you sure? Are you sure? Are you sure? Are you sure? Are you sure? Are you sure?") {
                        AlertAction(name: "Cancel", style: .cancel) {
                            print("cancelled")
                        }
                        AlertAction(name: "OK", style: .default) {
                            print("comfirmed")
                        }
                    }
                }
                .padding(top: 10, leading: 10, bottom: 10, trailing: 10)
                .backgroundColor(.gray)
                .alignment(.center)
        }
        // Do any additional setup after loading the view.
    }
}
