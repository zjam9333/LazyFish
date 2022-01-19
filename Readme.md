# About This Light-weight Kit

Looks like SwiftUI, define and layout the UIView using Swift DSL.

Under Construction! Get Away From Production!

# How to Use

add something in your Podfile

```ruby
platform :ios, '9.0'
target 'LazyFishTest' do
	use_frameworks!
	pod 'LazyFish', :git => 'https://whereIsThePodGit', :branch => 'whichBranch'
end
```

show a Text Label in center:

```swift
self.view.arrangeViews {
    UILabel()
        .text("Hello World")
        .alignment(.center)
}
```

## pros:

- you can keep all your old `UIViewController`s, `UIView`s and anything
- writing UIView like SwiftUI
- support `iOS 9`

## cons:

- can not automatically refresh UI using if/else/for..in.. statements, using IfBlock(...)/ForEach(...) instead
- need to test
- lack of many UIView modifier (using KeyPath)
- lack of animation modifier
- lack of .. a lot of features

# Updates

- 2022-01-19 Add `GeometryReader`. `Binding<T>` supports `dynamic member lookup`

```swift
public struct GeometryProxy {
    public var size: CGSize = .zero
}

GeometryReader { geo: Binding<GeometryProxy> in
    UIButton("ABC")
        .action {
            print("button")
        }
        .frame(width: geo.size.width / 2, height: geo.size.height - 30 * 2)
        .backgroundColor(.red)
        .alignment([.top, .leading], value: 100)

        // that "geo.size.width" is "dynamic member lookup"
}
```

- 2022-01-13 Add a simple animation demo

```swift
@State private var alertScale: CGFloat = 0.1

view.property(\.transform, binding: $alertScale.map {
    scale -> CGAffineTransform in
    return .identity.scaledBy(x: scale, y: scale)
})

alertScale = 1
```

- 2021-12-23 `UIView` supports `keyPath` and `binding` modifier

Example: `UILabel` changing a Color

```swift
// static
UILabel()
    .property(\.textColor, value: isTrue ? .green : .red)

// dynamic
@State var isTrue: Bool = true
UILabel()
    .property(\.textColor, binding: $isTrue.map { b -> UIColor in 
        b ? .green : .red
    })
```

- 2021-12-16 `Binding` supports `join`

Join 2 Binding objects, `A + B = (A, B)`, or `A + B = C`

```swift
@State var text1: String = "cde"
@State var text2: String = "fgab"
@State var number3: Int = 100

let joined2Ojb: Binding<(String, Int)> = $text1.join($number3)

let joined3Obj: Binding<String> = $text1.join($text2) { s1, s2 in
    return s1 + "_" + s2
}

label.text(binding: joined3Obj)
```

- 2021-12-7 `Binding` supports `map`

turn `Binding<A>` into `Binding<B>`, create a `Binding<Bool>` where `IfBlock` needs

```swift
@State var text1: String = "abcdefg"

// Binding<String> -> Binding<Bool>
let mapCondition = $text.map { s in
    return s.hasPrefix("abc")
}

IfBlock(mapCondition) {
    // views...
}

// or
IfBlock($text.map { s in
    return s.hasPrefix("abc")
}) {
    // views...
}
```

- 2021-12-6 IfElseView、ForEachView touches ignored

- 2021-11-18 add If, Else condition block

- 2021-10-28 add ForEach loop block

- 2021-10-9 First Commit

# Basic

## view add subviews

```swift
someView.arrangeViews {
    view1
    view2
    view3
}
```

which will create views like this

```swift
someView
    \
    ---view1
    ---view2
    ---view3
```

## UIview, UILabel, UIButton, UIImageView ...

```swift
UIView {
    // sub1...
    // sub2...
    // subn...
    // align according to .alignment(...) function
}
```

## Stack

```swift
UIStackView(axis: .horizontal， distribution: .fill, alignment: .fill, spacing: 0) {
    // sub1...
    // sub2...
    // subn...
}
```

## Scroll Stack

```swift
UIScrollView(.vertical, spacing: CGFloat = 0) {
    // sub1...
    // sub2...
    // subn...
}
```

```
scrollview
    \
    ---internalStackView
        \
        ---view1
        ---view2
        ---view3
```

## If Block

Arguments: `Binding<Bool>`, returns: `[IfBlockView]`, automatically shows or hides `ifContent` and `elseContent`

If you using `if ... {} else ... {}` condition pattern, it will not refresh. Just use this ugly `IfBlock`

```swift
IfBlock(self?.$showPage1) {
    view1
    view2
} 
// or
IfBlock(self?.$showPage1) {
    view1
    view2
} contentElse: {
    view3
}
```

If the `IfBlockView` is in a Stack:

```swift
someStack
    \
    IfBlockView
        \
        ---internalStackView
            \
            // if
            ---view1
            ---view2
            // else
            ---view3 // isHidden
```

Otherwise:

```swift
someNotStack
    \
    IfBlockView
        \
        // if
        ---view1
        ---view2
        // else
        ---view3 // isHidden
```

## ForEach

arguments: `Binding<[T]>`, return `ForEachView<T>`

as stated above, using `for i in array {}` will not refresh. Just use the ugly `ForEach`

```swift
ForEach($array) { item in
    view1
    view2
    view3
}
```

```swift
someStack
    \
    ForEachView<T>
        \
        ---internalStackView
            \
            ---view1
            ---view2
            ---view3
```

```swift
someNotStack
    \
    ForEachView<T>
        \
        ---view1
        ---view2
        ---view3
```

## Tableview (did not finish)

TODO: `Cell Reuse`

Example:

```swift
@State var arr1: String = ["Dog", "Cat", "Fish"]
var arr2: String = ["Tom", "Jerry", "Butch"]

UITableView(style: .grouped) {
    // dynamic section
    TableViewSection(binding: $arr1) { item in
        UILabel()
            .text("dynamic row: \(item)")
            .alignment(.leading, value: 20)
            .alignment(.centerY)
    } action: { [weak self] item in
        // did selected cell
    }

    // staic section
    TableViewSection(arr2) { item in
        UILabel()
            .text("static row: \(item)")
            .alignment(.leading, value: 20)
            .alignment(.centerY)
    }
}
```

if there is only one static section:

```swift
UITableView(style: .plain, array: testClasses) { item in
    let title = item.name
    UILabel().text(title)
        .alignment(.leading, value: 20)
        .alignment(.centerY)
} action: { [weak self] item in
    // ...
}
```

# Modifiers

Using function to modify some properties, and return `self`, which looks like SwiftUI

Examples, defined in `modifier.swift`:

if you can't find any modifier that you wanted, use this `keyPath` function:

```swift
public extension UIView {
    func property<Value>(_ keyPath: WritableKeyPath<Self, Value>, binding: Binding<Value>?) -> Self
    func property<Value>(_ keyPath: WritableKeyPath<Self, Value>, value newValue: Value) -> Self
}
```

## UIView

```swift
public extension UIView {
    func backgroundColor(_ color: UIColor) -> Self
    func cornerRadius(_ cornerRadius: CGFloat) -> Self
    func clipped() -> Self
    func borderColor(_ color: UIColor) -> Self
    func borderWidth(_ width: CGFloat) -> Self
    func border(width: CGFloat, color: UIColor) -> Self
}
```

## UILabel

```swift
public extension UILabel {
    func text(_ text: String) -> Self
    func textColor(_ color: UIColor) -> Self
    func textAlignment(_ alignment: NSTextAlignment) -> Self
    func numberOfLines(_ lines: Int) -> Self
    func font(_ font: UIFont) -> Self
}
public extension UILabel {
    // stateText
    func text(binding stateText: Binding<String>) -> Self
}
```

## UIControl, UIButton

```swift
public extension UIControl {
    typealias ActionBlock = () -> Void
    func action(for event: Event = .touchUpInside, _ action: @escaping ActionBlock) -> Self
    func textAlignment(_ alignment: ContentHorizontalAlignment) -> Self
}
```

# Alignment Attributes

## alignments constraint

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

## size constraint

```swift
func frame(width: CGFloat, height: CGFloat) -> Self
func frame(width: Binding<CGFloat>, height: Binding<CGFloat>) -> Self
```

## padding container

it will create a `PaddingView` as superview

```swift 
func padding(top: CGFloat? = nil, leading: CGFloat? = nil, bottom: CGFloat? = nil, trailing: CGFloat? = nil) -> Self
```

# State Property

`@State` property wrapper, makes properties observable:

```swift
@State var text: String = "abc"
```

it will create these properties automatically:

```swift
var _text: State<String>
var $text: Binding<String> { get }
```

`UILabel`, `UIButton`, `UITextField` with `Binding<String>`, will refresh its text while `text` changing.

Example: `UILabel` binds to a `text`

```swift 
public extension UILabel {
    func text(binding stateText: Binding<String>?) -> Self {
        stateText?.addObserver(target: self) { [weak self] changed in
            self?.text = changed.new
        }
        return self
    }
}
```

```swift
@State var text: String = "abc"
///...
self.view.arrangeViews {
    UIlabel().text(self.$text)
}
```

## Binding extensions

`Binding<T>` objects may not easy to use.

For example:

In this case, we need to turn `Binding<String>` into `Binding<Bool>` which `IfBlock` required, so we use `map` function.

```swift
@State var text: String = "abc"

IfBlock( $text.map { t in
    return t.hasPrefix("a")
} ) {
    // views
}
```

Other example:

we want to combine two or more `Binding` objects into one, so we use `join` function.

```swift
@State var text: String = "abc"
@State var text2: String = "efg"

IfBlock( $text.join($text2) { t, t2 in
    return t.hasPrefix(t2)
} ) {
    // views
}
```

# GeometryReader

`GeometryReader` in SwiftUI is very hard to understand, i'm trying to make it simple.

Our `GeometryReader` is a UIView, it passes a `Binding<GeometryProxy>` object in closure, you can using its `size` property to layout your views' size

```swift
GeometryReader { geo: Binding<GeometryProxy> in
    UIButton("ABC")
        .action {
            print("button")
        }
        .frame(width: geo.size.width / 2, height: geo.size.height - 30 * 2)
        .backgroundColor(.red)
        .alignment([.top, .leading], value: 100)
}
```


