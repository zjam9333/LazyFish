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
        let obs = obj.observe(keyPath, options: [.initial, .new]) { view, change in
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
    var userCreatedContents: [UIView] { get set }
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

    func didAddToSuperStackView(_ superStack: UIStackView) {
        if let view = self as? UIView {
            for i in userCreatedContents {
                i.removeFromSuperview()
            }
            view.arrangeViews {
                InternalLayoutStackView(axis: superStack.axis, distribution: superStack.distribution, alignment: superStack.alignment, spacing: superStack.spacing) {
                    userCreatedContents
                }.alignment(.allEdges)
            }
        }
    }
}

internal class PaddingContainerView: UIView, ObserveContainer {
    var observeSubviewTokens: [NSKeyValueObservation] = []
    func addContentView(_ content: UIView, padding: [Edge: CGFloat] = [:], offset: CGPoint = .zero) {
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
    var userCreatedContents: [UIView] = []
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
    return ForEachEnumerated(models) { index, model in
        contents(model)
    }
}

public func ForEachEnumerated<T>(_ models: Binding<[T]>?, @ViewBuilder contents: @escaping (Int, T) -> [UIView]) -> UIView {
    let container = ForEachView()
    models?.wrapper.addObserver(target: container) { [weak container] changed in
        container?.reloadSubviews(changed.new, contentBuilder: contents)
    }
//    container.actionWhileMoveToWindow.append { [weak container] in
//        container?.reloadSubviews(models?.wrapper.wrappedValue ?? [], contentBuilder: contents)
//    }
    return container
}

internal class ForEachView: UIView, FakeInternalContainer {
    var observeSubviewTokens: [NSKeyValueObservation] = []
    var actionWhileMoveToWindow: [() -> Void] = []
    var userCreatedContents: [UIView] = []
    override func didMoveToWindow() {
        super.didMoveToWindow()
        excuteAllActionsWhileMoveToWindow()
    }
    
    func reloadSubviews<T>(_ models: [T], contentBuilder: ((Int, T) -> [UIView])?) {
//        guard let _ = self.window else {
//            return
//        }
        let allSubviews = subviews
        for i in allSubviews {
            i.removeFromSuperview()
        }
        userCreatedContents.removeAll()
        removeAllSubviewObservations()
        // 重新加载全部！！！如何优化？
        
        let views = models.enumerated().map { i, m in
            contentBuilder?(i, m) ?? []
        }.flatMap { t in
            t
        }
        
        if views.isEmpty {
            self.isHidden = true
            return
        }
        
        arrangeViews {
            views
        }
        userCreatedContents.append(contentsOf: views)
        if let stack = self.superview as? UIStackView {
            didAddToSuperStackView(stack)
        }
        
        for i in userCreatedContents {
            observe(obj: i, keyPath: \.isHidden) { [weak self] isHidden in
                self?.isHidden = self?.hasNoSubviewShown(self?.userCreatedContents ?? []) ?? false
            }
        }
        isHidden = hasNoSubviewShown(userCreatedContents)
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
    let ifview = IfBlockView(conditionContents: contentIf)
    let elseview = ElseBlockView(conditionContents: contentElse)
    if ifview == nil && elseview == nil {
        return []
    }
    var views = [UIView]()
    if let ifview = ifview {
        observe?.wrapper.addObserver(target: ifview) { [weak ifview] changed in
            let present = map(changed.new)
            ifview?.isHidden = !present
        }
        views.append(ifview)
    }
    if let elseview = elseview {
        observe?.wrapper.addObserver(target: elseview) { [weak elseview] changed in
            let present = map(changed.new)
            elseview?.isHidden = present
        }
        views.append(elseview)
    }
    return views
}

internal class ElseBlockView: IfBlockView {
    
}

internal class IfBlockView: UIView, FakeInternalContainer {
    var observeSubviewTokens: [NSKeyValueObservation] = []
    var actionWhileMoveToWindow: [() -> Void] = []
    var userCreatedContents: [UIView] = []
    override func didMoveToWindow() {
        super.didMoveToWindow()
        excuteAllActionsWhileMoveToWindow()
    }
    
    convenience init?(@ViewBuilder conditionContents: ViewBuilder.ContentBlock) {
        let contents = conditionContents()
        if contents.isEmpty {
            return nil
        }
        self.init()
        userCreatedContents = contents
        arrangeViews {
            contents
        }
        for i in userCreatedContents {
            observe(obj: i, keyPath: \.isHidden) { [weak self] isHidden in
                self?.isHidden = self?.hasNoSubviewShown(self?.userCreatedContents ?? []) ?? false
            }
        }
    }
}
