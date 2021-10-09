#  ZKit

## Demo 

![demo img](demo.png)

```swift
self.view.arrangeViews {
    UIScrollView(.vertical) {
        for row in 0..<10 {
            UIView {
                UIStackView(axis: .horizontal, alignment: .center, spacing: 10) {
                    UIView()
                        .backgroundColor(UIColor(hue: CGFloat.random(in: 0...1), saturation: 1, brightness: 1, alpha: 1))
                        .cornerRadius(4)
                        .frame(width: 40, height: 40)
                    
                    UIStackView(axis: .vertical, alignment: .leading) {
                        UILabel().text("Title text \(row)")
                            .textColor(.label)
                            .font(.systemFont(ofSize: 17, weight: .semibold))
                        UILabel().text("Detail text Detail text Detail text \(row)")
                            .textColor(.lightGray)
                            .font(.systemFont(ofSize: 14, weight: .regular))
                    }
                }
                .frame(alignment: [.leading, .centerY])
                .margin(leading: 12)
                
                UIView()
                    .backgroundColor(.lightGray)
                    .frame(height: 0.5, alignment: [.leading, .bottom, .trailing])
                    .margin(leading: 12)
            }.frame(height: 60)
            
        }
    }
    .frame(alignment: .allEdges)
    .bounce(.vertical)
}

```

