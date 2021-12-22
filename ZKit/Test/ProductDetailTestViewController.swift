//
//  ProductDetailTestViewController.swift
//  ZKit
//
//  Created by zjj on 2021/12/6.
//

import UIKit
import ZKitCore

///
///以下demo仅按照个人口味作演示，并不代表必须这样写
///所有view堆在一个block里面写，会使得代码提示出现压力
///

class ProductDetailTestViewController: UIViewController {
    struct Media {
        
    }
    
    struct Product {
        var images: [Media] = [Media(), Media(), Media()]
        var moreImages: [Media] = [Media(), Media()]
        var name: String = "平底锅平底锅平底锅平底锅平底锅平底锅平底锅平底锅平底锅平底锅名称"
        var summary: String = "平底锅平底锅平底摘要摘要"
        var description: String = "平底锅平底锅平底详情详情"
        var onSell: Bool = true
    }
    
    enum Item {
        case mainImages
        case name
        case summary
        case description
        case moreImages
        case spu
        case sku
        case moreSku(Bool)
        case onSell
        case category
        case setting
    }
    
    @State var product: Product = Product() {
        didSet {
            
        }
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
    @State var section3: [Item] = [
        .spu,
        .sku,
        .sku,
        .moreSku(false),
    ]
    let section4: [Item] = [
        .onSell,
        .category,
        .setting,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var style = UITableView.Style.grouped
        if #available(iOS 13.0, *) {
            style = .insetGrouped
        }
        
        view.arrangeViews {
            UITableView(style: style) {
                tableViewSection1()
                tableViewSection2()
                tableViewSection3()
                tableViewSection4()
            }
            .alignment(.allEdges)
        }
    }
    
    func openAllSkuList(_ open: Bool) {
        if open {
            self.section3 = [
                .spu,
                .sku,
                .sku,
                .sku,
                .sku,
                .sku,
                .sku,
                .sku,
                .sku,
                .moreSku(true),
            ]
        } else {
            self.section3 = [
                .spu,
                .sku,
                .sku,
                .moreSku(false),
            ]
        }
    }
    
    func simpleCellContent(@ViewBuilder _ content: ViewBuilder.ContentBlock) -> UIView {
        return UIView {
            content()
            UIImageView(image: UIImage(named: "next"))
                .alignment([.centerY, .trailing])
        }
        .padding(16)
        .alignment(.allEdges)
    }
    
    func tableViewSection1() -> Section {
        return Section(section1) { [weak self] item in
            UIStackView(axis: .vertical, spacing: 20) {
                UIView {
                    UILabel("商品主要图片")
                        .font(.systemFont(ofSize: 20, weight: .semibold))
                        .textColor(.black)
                        .alignment([.centerY, .leading, .top])
                    UILabel("查看全部")
                        .font(.systemFont(ofSize: 16, weight: .regular))
                        .textColor(.systemBlue)
                        .alignment([.centerY, .trailing])
                }
                
                UIScrollView(.horizontal, spacing: 10) {
                    ForEachEnumerated(self?.$product.map { pro in
                        return pro.images
                    }) { index, img in
                        let height: CGFloat = 120
                        UIView()
                            .frame(width: height, height: height)
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
    }
    
    func tableViewSection2() -> Section {
        return Section(section2) { [weak self] item in
            switch item {
            case .name:
                UIStackView(axis: .vertical, spacing: 20) {
                    UILabel("商品信息")
                        .font(.systemFont(ofSize: 20, weight: .semibold))
                        .textColor(.black)
                    UIStackView(axis: .vertical, spacing: 10) {
                        UILabel("商品名称")
                            .font(.systemFont(ofSize: 16, weight: .regular))
                            .textColor(.lightGray)
                        UIStackView(axis: .horizontal, alignment: .top, spacing: 10) {
                            UILabel()
                                .text(binding: self?.$product.map { pro in
                                    return pro.name
                                })
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
                self?.simpleCellContent {
                    UILabel("编辑商品摘要")
                        .font(.systemFont(ofSize: 16, weight: .semibold))
                        .textColor(.black)
                        .alignment([.centerY, .top, .leading])
                }
            case .description:
                self?.simpleCellContent {
                    UILabel("编辑商品描述")
                        .font(.systemFont(ofSize: 16, weight: .semibold))
                        .textColor(.black)
                        .alignment([.centerY, .top, .leading])
                }
            case .moreImages:
                self?.simpleCellContent {
                    UILabel()
                        .text(binding: self?.$product.map { pro in
                            return "更多商品图片(\(pro.moreImages.count)/20)"
                        })
                        .font(.systemFont(ofSize: 16, weight: .semibold))
                        .textColor(.black)
                        .alignment([.centerY, .top, .leading])
                }
            default:
                []
            }
        } action: { item in
            
        }
    }
    
    func tableViewSection3() -> Section {
        return Section(binding: self.$section3) { [weak self] item in
            switch item {
            case .spu:
                UIStackView(axis: .vertical, spacing: 20) {
                    UILabel("价格与库存")
                        .font(.systemFont(ofSize: 20, weight: .semibold))
                        .textColor(.black)
//                                .frame(height: 20)
                    
                    UIStackView(axis: .horizontal, alignment: .top, spacing: 10) {
                        
                        UIStackView(axis: .vertical, spacing: 10) {
                            UILabel("主商品")
                                .font(.systemFont(ofSize: 16, weight: .regular))
                                .textColor(.black)
                        
                            UILabel()
                                .text(binding: self?.$product.map({ p in
                                    return "商品货号：\(100)\n原价格：\(200)\n特价：\(300)\n成本价：\(10)"
                                }))
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
                            .font(.systemFont(ofSize: 16, weight: .semibold))
                            .textColor(.black)
                        UILabel()
                            .text(binding: self?.$product.map({ p in
                                return "商品货号：\(100)\n原价格：\(200)\n特价：\(300)\n成本价：\(10)"
                            }))
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
            case .moreSku(let opened):
                UILabel(opened ? "收起全部规格" : "查看全部规格")
                    .font(.systemFont(ofSize: 16, weight: .regular))
                    .textColor(.systemBlue)
                    .padding(top: 0, leading: 16, bottom: 16, trailing: 16)
                    .alignment(.allEdges)
            default:
                []
            }
        } action: { [weak self] item in
            if case .moreSku(let opened) = item {
                self?.openAllSkuList(!opened)
            }
        }
    }
    
    func tableViewSection4() -> Section {
        return Section(section4) { [ weak self] item in
            switch item {
            case .onSell:
                UIView {
                    UILabel("网店上架商品")
                        .font(.systemFont(ofSize: 16, weight: .semibold))
                        .textColor(.black)
                        .alignment([.centerY, .top, .leading])
                    UISwitch()
                        .isOn(binding: self?.$product.map { b in
                            return b.onSell
                        }) { fi in
                            self?.product.onSell = fi
                        }
                        .alignment([.centerY, .trailing])
                }
                .padding(16)
                .alignment(.allEdges)
            case .category:
                self?.simpleCellContent {
                    UILabel("分类")
                        .font(.systemFont(ofSize: 16, weight: .semibold))
                        .textColor(.black)
                        .alignment([.centerY, .top, .leading])
                }
            case .setting:
                self?.simpleCellContent {
                    UILabel("设定")
                        .font(.systemFont(ofSize: 16, weight: .semibold))
                        .textColor(.black)
                        .alignment([.centerY, .top, .leading])
                }
            default:
                []
            }
        } action: { item in
            
        }
    }
}
