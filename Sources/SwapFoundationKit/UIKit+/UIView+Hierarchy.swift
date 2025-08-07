/*****************************************************************************
 * UIView+Hierarchy.swift
 * SwapFoundationKit
 *****************************************************************************
 * Copyright (c) 2025 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit
#endif

#if canImport(UIKit) && os(iOS)
@MainActor
public extension UIView {
    /// Adds multiple subviews to the current view.
    /// - Parameter views: An array of views to add as subviews.
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
    
    /// Adds multiple subviews to the current view.
    /// - Parameter views: A variadic list of views to add as subviews.
    func addSubviews(_ views: UIView...) {
        addSubviews(views)
    }
    
    /// Returns all subviews of a specific type in the view hierarchy.
    /// - Parameter type: The type of views to find.
    /// - Returns: An array of subviews of the specified type.
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard !view.subviews.isEmpty else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
    
    /// Removes all subviews from the current view.
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// Returns the first superview of a specific type.
    /// - Parameter type: The type of superview to find.
    /// - Returns: The first superview of the specified type, or nil if not found.
    func firstSuperview<T: UIView>(of type: T.Type) -> T? {
        var current = superview
        while let view = current {
            if let target = view as? T {
                return target
            }
            current = view.superview
        }
        return nil
    }
    
    /// Returns all superviews of a specific type.
    /// - Parameter type: The type of superviews to find.
    /// - Returns: An array of superviews of the specified type.
    func allSuperviews<T: UIView>(of type: T.Type) -> [T] {
        var superviews: [T] = []
        var current = superview
        while let view = current {
            if let target = view as? T {
                superviews.append(target)
            }
            current = view.superview
        }
        return superviews
    }
}
#endif
