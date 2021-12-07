//
//  ProductDetailTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/12/6.
//

import UIKit
import ZKitCore

class ProductDetailTestViewController: UIViewController {
    
    enum Item {
        case mainImages
        case name
        case summary
        case description
        case moreImages
        case spu
        case sku
        case moreSku
        case onSell
        case category
        case setting
    }

    let section1: [Item] = [
        .mainImages,
    ]
    let section2: [Item] = [
        .name,
        .summary,
        .description,
        .moreImages,
    ]
    let section3: [Item] = [
        .spu,
        .sku,
        .sku,
        .moreSku,
    ]
    let section4: [Item] = [
        .onSell,
        .category,
        .setting,
    ]
    
    @State var mainImages = [Int]([1, 2, 3, 4, 5, 6, 7])
    @State var name: String = "平底锅平底锅平底锅平底锅平底锅平底锅平底锅平底锅平底锅平底锅"
//    @State var more
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var style = UITableView.Style.grouped
        if #available(iOS 13.0, *) {
            style = .insetGrouped
        }
        
        
        let imageViewChevronRightCircle = { () -> UIImageView in
            var imageChevronRightCircle: UIImage?
            if #available(iOS 13.0, *) {
                imageChevronRightCircle = UIImage(systemName: "chevron.right.circle")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
            return UIImageView(image: imageChevronRightCircle).tintColor(.lightGray)
        }
        
        view.arrangeViews {
            UITableView(style: style) { [weak self] in
                Section(section1) { item in
                    UIStackView(axis: .vertical, spacing: 20) {
                        UIView {
                            UILabel("商品主要图片")
                                .font(.systemFont(ofSize: 20, weight: .bold))
                                .textColor(.black)
                                .alignment([.centerY, .leading, .top])
                            UILabel("商品主要图片")
                                .font(.systemFont(ofSize: 16, weight: .regular))
                                .textColor(.systemBlue)
                                .alignment([.centerY, .trailing])
                        }
                        
                        UIScrollView(.horizontal, spacing: 10) {
                            ForEachEnumerated(self?.$mainImages) { index, img in
                                UIView()
                                    .frame(width: 82, height: 82)
                                    .backgroundColor(.lightGray)
                                    .cornerRadius(6)
                            }
                        }
                        .clipped(false)
                        .bounce(.horizontal)
                    }
                    .padding(16)
                    .alignment(.allEdges)
                } action: { item in
                    
                }
                
                Section(section2) { item in
                    switch item {
                    case .name:
                        UIStackView(axis: .vertical, spacing: 20) {
                            UILabel("商品信息")
                                .font(.systemFont(ofSize: 20, weight: .bold))
                                .textColor(.black)
                            UIStackView(axis: .vertical, spacing: 10) {
                                UILabel("商品名称")
                                    .font(.systemFont(ofSize: 16, weight: .regular))
                                    .textColor(.lightGray)
                                UIStackView(axis: .horizontal, alignment: .top, spacing: 10) {
                                    UILabel().text(binding: self?.$name)
                                        .font(.systemFont(ofSize: 16, weight: .regular))
                                        .numberOfLines(0)
                                        .textColor(.black)
                                    UILabel("更多")
                                        .font(.systemFont(ofSize: 16, weight: .regular))
                                        .textColor(.systemBlue)
                                        .frame(width: 48).textAlignment(.right)
                                }
                            }
                        }
                        .padding(16)
                        .alignment(.allEdges)
                    case .summary:
                        UIView {
                            UILabel("编辑商品摘要")
                                .font(.systemFont(ofSize: 16, weight: .bold))
                                .textColor(.black)
                                .alignment([.centerY, .top, .leading])
                            imageViewChevronRightCircle()
                                .alignment([.centerY, .trailing])
                        }
                        .padding(16)
                        .alignment(.allEdges)
                    case .description:
                        UIView {
                            UILabel("编辑商品描述")
                                .font(.systemFont(ofSize: 16, weight: .bold))
                                .textColor(.black)
                                .alignment([.centerY, .top, .leading])
                            imageViewChevronRightCircle()
                                .alignment([.centerY, .trailing])
                            
                        }
                        .padding(16)
                        .alignment(.allEdges)
                    case .moreImages:
                        UIView {
                            UILabel("更多商品图片(2/20)")
                                .font(.systemFont(ofSize: 16, weight: .bold))
                                .textColor(.black)
                                .alignment([.centerY, .top, .leading])
                            imageViewChevronRightCircle()
                                .alignment([.centerY, .trailing])
                        }
                        .padding(16)
                        .alignment(.allEdges)
                    default:
                        []
                    }
                } action: { item in
                    
                }

                Section(section3) { item in
                    switch item {
                    case .spu:
                        UIStackView(axis: .vertical, spacing: 20) {
                            UILabel("价格与库存")
                                .font(.systemFont(ofSize: 20, weight: .bold))
                                .textColor(.black)
                                .frame(height: 20)
                            
                            UIStackView(axis: .horizontal, alignment: .top, spacing: 10) {
                                
                                UIStackView(axis: .vertical, spacing: 10) {
                                    UILabel("主商品")
                                        .font(.systemFont(ofSize: 16, weight: .regular))
                                        .textColor(.black)
                                
                                    UILabel("商品货号：\n原价格：\n特价：\n成本价：")
                                        .font(.systemFont(ofSize: 16, weight: .regular))
                                        .numberOfLines(0)
                                        .textColor(.lightGray)
                                }
                                UILabel("更多")
                                    .font(.systemFont(ofSize: 16, weight: .regular))
                                    .textColor(.systemBlue)
                                    .frame(width: 48).textAlignment(.right)
                            }
                        }
                        .padding(16)
                        .alignment(.allEdges)
                    case .sku:
                        UIStackView(axis: .horizontal, alignment: .top, spacing: 16) {
                            UIView().backgroundColor(.lightGray)
                                .frame(width: 60, height: 60)
                                .cornerRadius(5)
                            UIStackView(axis: .vertical, spacing: 10) {
                                UILabel("款式")
                                    .font(.systemFont(ofSize: 16, weight: .bold))
                                    .textColor(.black)
                                UILabel("商品货号：\n原价格：\n特价：\n成本价：")
                                    .font(.systemFont(ofSize: 16, weight: .regular))
                                    .numberOfLines(0)
                                    .textColor(.lightGray)
                            }
                            UILabel("更多")
                                .font(.systemFont(ofSize: 16, weight: .regular))
                                .textColor(.systemBlue)
                                .frame(width: 48).textAlignment(.right)
                        }
                        .padding(16)
                        .alignment(.allEdges)
                    case .moreSku:
                        UILabel("查看全部规格")
                            .font(.systemFont(ofSize: 16, weight: .regular))
                            .textColor(.systemBlue)
                            .padding(top: 0, leading: 16, bottom: 16, trailing: 16)
                            .alignment(.allEdges)
                    default:
                        []
                    }
                } action: { item in
                    
                }
                
                Section(section4) { item in
                    switch item {
                    case .onSell:
                        UIView {
                            UILabel("网店上架商品")
                                .font(.systemFont(ofSize: 16, weight: .bold))
                                .textColor(.black)
                                .alignment([.centerY, .top, .leading])
                            UISwitch()
                                .alignment([.centerY, .trailing])
                        }
                        .padding(16)
                        .alignment(.allEdges)
                    case .category:
                        UIView {
                            UILabel("分类")
                                .font(.systemFont(ofSize: 16, weight: .bold))
                                .textColor(.black)
                                .alignment([.centerY, .top, .leading])
                            imageViewChevronRightCircle()
                                .alignment([.centerY, .trailing])
                        }
                        .padding(16)
                        .alignment(.allEdges)
                    case .setting:
                        UIView {
                            UILabel("设定")
                                .font(.systemFont(ofSize: 16, weight: .bold))
                                .textColor(.black)
                                .alignment([.centerY, .top, .leading])
                            imageViewChevronRightCircle()
                                .alignment([.centerY, .trailing])
                        }
                        .padding(16)
                        .alignment(.allEdges)
                    default:
                        []
                    }
                } action: { item in
                    
                }
            }
            .alignment(.allEdges)
        }
    }
}
