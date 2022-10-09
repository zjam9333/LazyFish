//
//  SwiftUIView.swift
//  LazyFishTest
//
//  Created by zjj on 2022/10/9.
//

import LazyFishCore
import SwiftUI

@available(iOS 13.0, *)
struct Preview: PreviewProvider {
    static var previews: some View {
        SwiftUIViewPresent {
            let title = UIView {
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
            }
                .cornerRadius(20)
                .backgroundColor(.init(white: 0.9, alpha: 1))
            
            let message = UIView {
                UIStackView(axis: .vertical, spacing: 16) {
                    UILabel("详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明详细说明")
                        .font(.systemFont(ofSize: 16, weight: .regular))
                        .numberOfLines(0)
                }
                .padding(16).alignment(.allEdges)
            }
                .cornerRadius(20)
                .backgroundColor(.init(white: 0.9, alpha: 1))
            
            UIScrollView(.vertical, spacing: 12) {
                title
                message
            }
            .alignment(.allEdges)
            .bounce(.vertical)
            .padding(20)
        }
        .background(Color(.red))
    }
}
