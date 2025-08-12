/*****************************************************************************
 * UIView+Layout.swift
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
    /// A struct to hold layout constraints for easy access and management.
    struct LayoutConstraints {
        var top, leading, bottom, trailing, width, height: NSLayoutConstraint?
    }
    
    /// The layout constraints for this view.
    var layoutConstraints: LayoutConstraints {
        get { objc_getAssociatedObject(self, &AssociatedKeys.layoutConstraints) as? LayoutConstraints ?? LayoutConstraints() }
        set { objc_setAssociatedObject(self, &AssociatedKeys.layoutConstraints, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Sets up Auto Layout constraints for the view.
    /// - Parameters:
    ///   - top: The top anchor constraint.
    ///   - leading: The leading anchor constraint.
    ///   - bottom: The bottom anchor constraint.
    ///   - trailing: The trailing anchor constraint.
    ///   - padding: The padding to apply to all edges.
    ///   - size: The size constraints.
    /// - Returns: The layout constraints that were created.
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?,
                bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?,
                padding: UIEdgeInsets = .zero, size: CGSize = .zero) -> LayoutConstraints {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = LayoutConstraints()
        
        if let top = top {
            constraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
            constraints.top?.isActive = true
        }
        
        if let leading = leading {
            constraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
            constraints.leading?.isActive = true
        }
        
        if let bottom = bottom {
            constraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
            constraints.bottom?.isActive = true
        }
        
        if let trailing = trailing {
            constraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
            constraints.trailing?.isActive = true
        }
        
        if size.width != 0 {
            constraints.width = widthAnchor.constraint(equalToConstant: size.width)
            constraints.width?.isActive = true
        }
        
        if size.height != 0 {
            constraints.height = heightAnchor.constraint(equalToConstant: size.height)
            constraints.height?.isActive = true
        }
        
        layoutConstraints = constraints
        return constraints
    }
    
    /// Centers the view within its superview.
    /// - Parameters:
    ///   - x: The x-axis center anchor.
    ///   - y: The y-axis center anchor.
    ///   - size: The size constraints.
    /// - Returns: The layout constraints that were created.
    @discardableResult
    func center(x: NSLayoutXAxisAnchor? = nil, y: NSLayoutYAxisAnchor? = nil, size: CGSize = .zero) -> LayoutConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = LayoutConstraints()
        
        if let x = x {
            constraints.leading = centerXAnchor.constraint(equalTo: x)
            constraints.leading?.isActive = true
        }
        
        if let y = y {
            constraints.top = centerYAnchor.constraint(equalTo: y)
            constraints.top?.isActive = true
        }
        
        if size.width != 0 {
            constraints.width = widthAnchor.constraint(equalToConstant: size.width)
            constraints.width?.isActive = true
        }
        
        if size.height != 0 {
            constraints.height = heightAnchor.constraint(equalToConstant: size.height)
            constraints.height?.isActive = true
        }
        
        layoutConstraints = constraints
        return constraints
    }
    
    /// Fills the view to its superview with optional padding.
    /// - Parameter padding: The padding to apply to all edges.
    /// - Returns: The layout constraints that were created.
    @discardableResult
    func fillSuperview(padding: UIEdgeInsets = .zero) -> LayoutConstraints {
        guard let superview = superview else { return LayoutConstraints() }
        return anchor(top: superview.topAnchor, leading: superview.leadingAnchor,
                     bottom: superview.bottomAnchor, trailing: superview.trailingAnchor,
                     padding: padding)
    }
    
    /// Centers the view within its superview.
    /// - Parameter size: The size constraints.
    /// - Returns: The layout constraints that were created.
    @discardableResult
    func centerInSuperview(size: CGSize = .zero) -> LayoutConstraints {
        guard let superview = superview else { return LayoutConstraints() }
        return center(x: superview.centerXAnchor, y: superview.centerYAnchor, size: size)
    }
    
    /// Sets the width and height constraints.
    /// - Parameter size: The size to set.
    /// - Returns: The layout constraints that were created.
    @discardableResult
    func anchorSize(to size: CGSize) -> LayoutConstraints {
        var constraints = LayoutConstraints()
        
        if size.width != 0 {
            constraints.width = widthAnchor.constraint(equalToConstant: size.width)
            constraints.width?.isActive = true
        }
        
        if size.height != 0 {
            constraints.height = heightAnchor.constraint(equalToConstant: size.height)
            constraints.height?.isActive = true
        }
        
        layoutConstraints = constraints
        return constraints
    }
    
    /// Sets the width constraint.
    /// - Parameter width: The width to set.
    /// - Returns: The width constraint that was created.
    @discardableResult
    func anchorWidth(to width: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalToConstant: width)
        constraint.isActive = true
        layoutConstraints.width = constraint
        return constraint
    }
    
    /// Sets the height constraint.
    /// - Parameter height: The height to set.
    /// - Returns: The height constraint that was created.
    @discardableResult
    func anchorHeight(to height: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalToConstant: height)
        constraint.isActive = true
        layoutConstraints.height = constraint
        return constraint
    }
}

public extension UIStackView {
    /// Adds multiple arranged subviews to the stack view.
    /// - Parameter views: An array of views to add as arranged subviews.
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
    
    /// Adds multiple arranged subviews to the stack view.
    /// - Parameter views: A variadic list of views to add as arranged subviews.
    func addArrangedSubviews(_ views: UIView...) {
        addArrangedSubviews(views)
    }
}

private struct AssociatedKeys {
    static var layoutConstraints = "layoutConstraints"
}
#endif 
