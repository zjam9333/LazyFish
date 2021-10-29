# ZKit介绍

类似SwiftUI，使用DSL布局UIView，但并非单纯的描述view，而是真正的创建view并布局

# 基础

`UIView`拓展了`arrangeViews(@ViewBuilder _ content: ViewBuilder.ContentBlock) -> Self`方法，是进入`DSL`声明布局的入口

其中`@ViewBuilder`修饰的方法和闭包将实现`DSL`功能并返回`Array<UIView>`，得到`UIView`数组后进行`addSubview()`或`addArrangedSubview()`，并使用`AutoLayout`约束

```swift
public typealias ViewBuilder = ResultBuilder<UIView>
@resultBuilder public struct ResultBuilder<MyReturnType> {
    public typealias ContentBlock = () -> [MyReturnType]
    // MARK: 组合全部表达式的返回值
    public static func buildBlock(_ components: [MyReturnType]...) -> [MyReturnType] {
        let res = components.flatMap { r in
            return r
        }
        return res
    }
    // MARK: 其他语法支持的buildBlock
    // static func buildBlock...
    // if\else\for..in..\while\等等等
}
```
关于`resultBuilder`的更多内容可以参考[Swift Result Builder](https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md)


在`@ViewBuilder`修饰的闭包中写入各种`view`，以及`alignment`、`frame`、`padding`等参数，甚至是`modifier`链式方法，即可实现布局和展示，例如在视图中央展示一个文本：

```swift
self.view.arrangeViews {
    UILabel()
    .text("Hello World")
    .alignment(.center)
}
```

# 布局相关Attribute

## 对齐约束alignment

在`非stack`中有效

```swift
func alignment(_ edges: Alignment, value: CGFloat? = 0) -> Self
public struct Alignment: OptionSet {
    public static let leading
    public static let trailing
    public static let top
    public static let bottom
    public static let allEdges: Alignment = [.leading, .trailing, .top, .bottom]
    public static let centerX
    public static let centerY
    public static let center: Alignment = [centerX, centerY]
}
```

## 大小约束frame

```swift
func frame(width: SizeFill? = nil, height: SizeFill? = nil) -> Self
public enum SizeFill {
    case fillParent
    case equalTo(_ size: CGFloat)
    // 更多规则未完待续
}
```

## 内边距padding

会在外部包装一个`PaddingView`

```swift 
func padding(top: CGFloat? = nil, leading: CGFloat? = nil, bottom: CGFloat? = nil, trailing: CGFloat? = nil) -> Self
```

## 一些状态监听

写了一个`propertyWrapper`用于修饰成员变量，模仿`SwiftUI`里的`@State`，但不完全一样，无需`Combine`框架

```swift
@propertyWrapper public class State<T> {
    public var wrappedValue: T
    public var projectedValue: Binding<T> {
        return Binding(wrapper: self)
    }
    public struct Changed<T> {
        let old: T
        let new: T
    }
    // 一些变量改动监听相关逻辑省略
    // ......
}

public struct Binding<T> {
    var wrapper: State<T>
}
```

在任意成员变量前使用`@State`修饰，例如
```swift
@State var text: String = "abc"
```
编译器会同时生成一对变量：
```swift
var _text: State<String>
var $text: Binding<String> { get }
```

在后续一些`UILabel`、`UIButton`、`UITextField`等传入`Binding<String>`即可自动同步可变的`text`内容，而非一次性写入的不可变`text`

例如使用`UITextField`监听并修改`text`变量
```swift
@State var text: String = "abc"
///...
self.view.arrangeViews {
    UITextField().text(self.$text)
}
```

# 自动刷新的If、ForEach（性能未完善)

使用普通的`if`、`for..in..`等语句虽然也能根据条件创建`view`，但无法监听和刷新（SwiftUI的精华之一就在这里），因此需要另外想办法

因暂未能重写原始的`if`语句和`for...in...`语句，便使用简单的函数代替

```swift
public func IfBlock(_ present: Binding<Bool>, @ViewBuilder content: ViewBuilder.ContentBlock, contentElse: ViewBuilder.ContentBlock = { [] }) -> [UIView]

public func IfBlock<T>(_ observe: Binding<T>, map: @escaping (T) -> Bool, @ViewBuilder contentIf: ViewBuilder.ContentBlock, @ViewBuilder contentElse: ViewBuilder.ContentBlock = { [] }) -> [UIView]

// example
IfBlock($showCake) {
    UILabel()
        .text("Cake")
        .borderColor(.blue).borderWidth(1)
}
UIButton()
    .text(str)
    .font(.systemFont(ofSize: 20, weight: .black))
    .textColor(.black)
    .textColor(.gray, for: .highlighted)
    .action { [weak self] in
        self?.showCake.toggle()
    }
```

当`IfBlock`传入的`Binding<T>`变量发生改变时，将自动设置`content`和`contentElse`里的`view`的`hidden`属性，达到自动展示隐藏的需要，在`UIStackView`中的`view`修改`hidden`属性会重新排列

注意：`content`和`contentElse`的内容会同时创建，按需创建的逻辑仍需优化

```swift
public func ForEach<T>(_ models: Binding<[T]>, @ViewBuilder contents: @escaping (T) -> [UIView]) -> ForEachView<T>

// example
ForEach($titles) { str in
    UILabel().text(str).alignment(.allEdges)
}
```

当`ForEach`传入的`Binding<[T]>`变量发生改变时，将重新使用`@ViewBuilder contents: @escaping (T) -> [UIView]`再次创建新的`view`

注意：因为存在刷新的可能，`contents`需要被引用，必要时主动标记`[weak self]`。刷新时全部内容会重新创建，仍需优化

# 一些简单Demos

## 文本输入和绑定

![text input example](doc/textinput.png)

Passing `$text` into a `UITextField`, will auto assign to the label which observes the `text` value

```swift
    @State var text: String = "abc"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.arrangeViews {
            UIView() {
                UIStackView(axis: .vertical, spacing: 10) {
                    UILabel().text("your input:")
                    UILabel().text(self.$text)
                    UITextField().text(self.$text).borderStyle(.roundedRect)
                }
                .padding(top: 10, leading: 10, bottom: 10, trailing: 10)
            }
            .borderWidth(1)
            .borderColor(.black)
            .alignment([.top, .centerX])
            .frame(width: 200)
            .padding(top: 160)
        }
        // Do any additional setup after loading the view.
    }
```

## 静态列表

![scrollview](doc/scrollview.png)

Using `UIScrollView`, `UIStackView`, `for..in..` ...

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

