//
//  Containers.swift
//  ZKitCore
//
//  Created by zjj on 2021/10/29.
//

import Foundation
import UIKit

protocol ObserveContainer: AnyObject {
    var observeSubviewTokens: [NSKeyValueObservation] { get set }
}

extension ObserveContainer {
    func removeAllSubviewObservations() {
        observeSubviewTokens.removeAll()
    }
    func observe<T: UIView, Value>(obj: T, keyPath: WritableKeyPath<T, Value>, action: @escaping (Value?) -> Void) {
        let obs = obj.observe(keyPath, options: .new) { view, change in
            action(change.newValue)
        }
        observeSubviewTokens.append(obs)
    }
    private func hasAnySubviewShown(_ views: [UIView]) -> Bool {
        if views.isEmpty {
            return false
        }
        let hasAnyShown = views.reduce(into: false) { anyShown, view in
            if view.isHidden == false {
                anyShown = true
            }
        }
        return hasAnyShown
    }
    func hasNoSubviewShown(_ views: [UIView]) -> Bool {
        return hasAnySubviewShown(views) == false
    }
}

protocol FakeInternalContainer: ObserveContainer {
    var actionWhileMoveToWindow: [() -> Void] { get set }
}

extension FakeInternalContainer {
    func seekTrullyContainer() -> UIView? {
        if let view = self as? UIView {
            let par = view.superview
            if let fakePar = par as? FakeInternalContainer {
                return fakePar.seekTrullyContainer()
            }
            return par
        }
        return nil
    }
    func excuteAllActionsWhileMoveToWindow() {
        for i in actionWhileMoveToWindow {
            i()
        }
        actionWhileMoveToWindow.removeAll()
    }
}

extension FakeInternalContainer where Self: UIView {
    func fakeContainerArranged(@ViewBuilder content: ViewBuilder.ContentBlock) {
        let views = content()
        // 如果和stack有关，则拷贝stack的属性
        if let superStack = self.superview as? UIStackView {
            self.arrangeViews {
                InternalLayoutStackView(axis: superStack.axis, distribution: superStack.distribution, alignment: superStack.alignment, spacing: superStack.spacing) {
                    views
                }.alignment(.allEdges)
            }
        } else {
            self.arrangeViews {
                views
            }
        }
    }
}

internal class PaddingContainerView: UIView, ObserveContainer {
    var observeSubviewTokens: [NSKeyValueObservation] = []
    func addContentView(_ content: UIView, padding: [Edge: CGFloat], offset: CGPoint = .zero) {
        self.addSubview(content)
        observe(obj: content, keyPath: \.isHidden) { [weak self] isHidden in
            self?.isHidden = self?.hasNoSubviewShown(self?.subviews ?? []) ?? false
        }
        
        content.translatesAutoresizingMaskIntoConstraints = false
        
        let offset: CGPoint = offset
        let top = offset.y + (padding[.top] ?? 0)
        let bottom = offset.y - (padding[.bottom] ?? 0)
        let leading = offset.x + (padding[.leading] ?? 0)
        let trailing = offset.x - (padding[.trailing] ?? 0)
        
        content.topAnchor.constraint(equalTo: self.topAnchor, constant: top).isActive = true
        content.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom).isActive = true
        content.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading).isActive = true
        content.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailing).isActive = true
    }
}

internal class InternalLayoutStackView: UIStackView, FakeInternalContainer {
    var observeSubviewTokens: [NSKeyValueObservation] = []
    var actionWhileMoveToWindow: [() -> Void] = []
    override func didMoveToWindow() {
        super.didMoveToWindow()
        excuteAllActionsWhileMoveToWindow()
    }
    
    override func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)
        
        observe(obj: view, keyPath: \.isHidden) { [weak self] isHidden in
            self?.isHidden = self?.hasNoSubviewShown(self?.arrangedSubviews ?? []) ?? false
        }
    }
}

// MARK: FOR_EACH

public func ForEach<T>(_ models: Binding<[T]>?, @ViewBuilder contents: @escaping (T) -> [UIView]) -> UIView {
    let container = ForEachView<T>()
    container.contentBuilder = contents
    models?.wrapper.addObserver { [weak container] changed in
        container?.reloadSubviews(changed.new)
    }
    container.actionWhileMoveToWindow.append { [weak container] in
        container?.reloadSubviews(models?.wrapper.wrappedValue ?? [])
    }
    return container
}

internal class ForEachView<T>: UIView, FakeInternalContainer {
    var observeSubviewTokens: [NSKeyValueObservation] = []
    var actionWhileMoveToWindow: [() -> Void] = []
    override func didMoveToWindow() {
        super.didMoveToWindow()
        excuteAllActionsWhileMoveToWindow()
    }
    
    var contentBuilder: ((T) -> [UIView])?
    
    func reloadSubviews(_ models: [T]) {
        guard let _ = self.window else {
            return
        }
        let allSubviews = self.subviews
        for i in allSubviews {
            i.removeFromSuperview()
        }
        // 重新加载全部！！！如何优化？
        
        let views = models.map { [weak self] m in
            self?.contentBuilder?(m) ?? []
        }.flatMap { t in
            t
        }
        self.fakeContainerArranged {
            views
        }
        
        removeAllSubviewObservations()
        for i in self.subviews {
            observe(obj: i, keyPath: \.isHidden) { [weak self] isHidden in
                self?.isHidden = self?.hasNoSubviewShown(self?.subviews ?? []) ?? false
            }
        }
        self.isHidden = self.hasNoSubviewShown(self.subviews)
    }
}

// MARK: IF

public func IfBlock(_ present: Binding<Bool>?, @ViewBuilder content: ViewBuilder.ContentBlock, @ViewBuilder contentElse: ViewBuilder.ContentBlock = { [] }) -> [UIView] {
    IfBlock(present, map: { a in
        return a
    }, contentIf: content, contentElse: contentElse)
}

public func IfBlock<T>(_ observe: Binding<T>?, map: @escaping (T) -> Bool, @ViewBuilder contentIf: ViewBuilder.ContentBlock, @ViewBuilder contentElse: ViewBuilder.ContentBlock = { [] }) -> [UIView] {
    return _View_IfBlock(observe, map: map, contentIf: contentIf, contentElse: contentElse)
}

// old without view container
private func _No_View_IfBlock<T>(_ observe: Binding<T>?, map: @escaping (T) -> Bool, @ViewBuilder contentIf: ViewBuilder.ContentBlock, @ViewBuilder contentElse: ViewBuilder.ContentBlock = { [] }) -> [UIView] {
    let viewsIf = contentIf()
    let viewsElse = contentElse()
    let all = viewsIf + viewsElse
    let allCount = all.count
    let ifCount = viewsIf.count
    for i in 0..<allCount {
        let vi = all[i]
        let isIf = i < ifCount
        observe?.wrapper.addObserver { [weak vi] changed in
            let present = map(changed.new)
            vi?.isHidden = isIf ? !present : present
        }
    }
    return all
}

// new ifblock using container
private func _View_IfBlock<T>(_ observe: Binding<T>?, map: @escaping (T) -> Bool, @ViewBuilder contentIf: ViewBuilder.ContentBlock, @ViewBuilder contentElse: ViewBuilder.ContentBlock = { [] }) -> [UIView] {
    let ifview = IfBlockView(ifBlockContents: contentIf)
    let elseview = IfBlockView(ifBlockContents: contentElse)
    if ifview == nil && elseview == nil {
        return []
    }
    observe?.wrapper.addObserver { [weak ifview, weak elseview] changed in
        let present = map(changed.new)
        ifview?.isHidden = !present
        elseview?.isHidden = present
    }
    var views = [UIView]()
    if let ifview = ifview {
        views.append(ifview)
    }
    if let elseview = elseview {
        views.append(elseview)
    }
    return views
}

internal class IfBlockView: UIView, FakeInternalContainer {
    var observeSubviewTokens: [NSKeyValueObservation] = []
    var actionWhileMoveToWindow: [() -> Void] = []
    override func didMoveToWindow() {
        super.didMoveToWindow()
        excuteAllActionsWhileMoveToWindow()
    }
    
    convenience init?(@ViewBuilder ifBlockContents: ViewBuilder.ContentBlock) {
        let contents = ifBlockContents()
        if contents.isEmpty {
            return nil
        }
        self.init()
        self.actionWhileMoveToWindow.append {
            [weak self] in
            self?.fakeContainerArranged {
                contents
            }
        }
        for i in self.subviews {
            observe(obj: i, keyPath: \.isHidden) { [weak self] isHidden in
                self?.isHidden = self?.hasNoSubviewShown(self?.subviews ?? []) ?? false
            }
        }
    }
}
