//
//  DemoTestViewController.swift
//  LazyFish
//
//  Created by zjj on 2021/10/9.
//

import UIKit
import LazyFishCore

class DemoTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let randomColor: () -> UIColor = {
            let color = UIColor(hue: CGFloat.random(in: 0...1), saturation: CGFloat.random(in: 0...1), brightness: CGFloat.random(in: 0...1), alpha: 1)
            return color
        }
        
        view.arrangeViews {
            UITableView(style: .plain) {
                Section(Array(0..<100)) { row in
                    UIStackView(axis: .horizontal, alignment: .center, spacing: 10) {
                        UIView()
                            .backgroundColor(randomColor())
                            .cornerRadius(4)
                            .frame(width: 40, height: 40)
                        
                        UIStackView(axis: .vertical, alignment: .leading, spacing: 6) {
                            UILabel().text("Title text \(row)")
                                .textColor(randomColor())
                                .font(.systemFont(ofSize: 17, weight: .semibold))
                            UILabel().text("Detail text Detail text Detail text \(row)")
                                .textColor(randomColor())
                                .font(.systemFont(ofSize: 14, weight: .regular))
                        }
                    }
                    .alignment([.leading, .centerY])
                    .alignment(.top, value: 12)
                    .padding(leading: 12)
                    
                    if #available(iOS 13.0, *) {
                        UIImageView(image: UIImage(systemName: "chevron.right"))
                            .alignment([.trailing, .centerY])
                            .padding(trailing: 10)
                    }
                    
                    UIView()
                        .backgroundColor(.lightGray.withAlphaComponent(0.5))
                        .frame(height: 0.5)
                        .alignment([.bottom, .trailing])
                        .alignment(.leading, value: 12)
                } action: { [weak self] item in
                    let vc = UIViewController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                    vc.navigationItem.title = "nothing title"
                    vc.view.backgroundColor = randomColor()
                }
            }
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
