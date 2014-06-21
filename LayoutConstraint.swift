//
//  LayoutConstraint.swift
//  Matrix
//
//  Created by Mark Onyschuk on 2014-06-19.
//  Copyright (c) 2014 Mark Onyschuk. All rights reserved.
//

#if os(iOS)
    
    import UIKit
    typealias LayoutView = UIView
    typealias LayoutPriority = UILayoutPriority
    
#elseif os(OSX)

    import Cocoa
    typealias LayoutView = NSView
    typealias LayoutPriority = NSLayoutPriority
    
#endif

struct LayoutAttribute {
    init(view: LayoutView, attribute: NSLayoutAttribute) {
        self.view = view
        self.attribute = attribute
    }
    
    var view: LayoutView
    var attribute: NSLayoutAttribute
}

struct LayoutRelation {
    init(from: LayoutAttribute, operator: NSLayoutRelation, to: LayoutAttribute) {
        self.to = to
        self.from = from
        self.operator = operator
    }
    
    var operator: NSLayoutRelation
    var from, to: LayoutAttribute
    
    // optional
    
    var constant = 0.0
    var multiplier = 1.0
    var priority :LayoutPriority = 1000
    
}

enum LayoutOption {
    case constant(Double), multiplier(Double), priority(LayoutPriority)
}

@infix func ==(lhs: LayoutAttribute, rhs: LayoutAttribute) -> LayoutRelation {
    return LayoutRelation(from: lhs, operator: .Equal, to: rhs)
}

@infix func <=(lhs: LayoutAttribute, rhs: LayoutAttribute) -> LayoutRelation {
    return LayoutRelation(from: lhs, operator: .LessThanOrEqual, to: rhs)
}

@infix func >=(lhs: LayoutAttribute, rhs: LayoutAttribute) -> LayoutRelation {
    return LayoutRelation(from: lhs, operator: .GreaterThanOrEqual, to: rhs)
}

@infix func &&(var lhs: LayoutRelation, rhs: LayoutOption) -> LayoutRelation {
    switch rhs {
    case let .priority(value):      lhs.priority = value
    case let .constant(value):      lhs.constant = value
    case let .multiplier(value):    lhs.multiplier = value
    }
    return lhs
}

extension LayoutView {
    
    // NOTE: declared as functions to avoid a Swift compiler bug in DP2
    
    func layoutTop()        -> LayoutAttribute {return LayoutAttribute(view: self, attribute: .Top)}
    func layoutLeft()       -> LayoutAttribute {return LayoutAttribute(view: self, attribute: .Left)}
    func layoutRight()      -> LayoutAttribute {return LayoutAttribute(view: self, attribute: .Right)}
    func layoutBottom()     -> LayoutAttribute {return LayoutAttribute(view: self, attribute: .Bottom)}
    
    func layoutLeading()    -> LayoutAttribute {return LayoutAttribute(view: self, attribute: .Leading)}
    func layoutTrailing()   -> LayoutAttribute {return LayoutAttribute(view: self, attribute: .Trailing)}
    
    func layoutWidth()      -> LayoutAttribute {return LayoutAttribute(view: self, attribute: .Width)}
    func layoutHeight()     -> LayoutAttribute {return LayoutAttribute(view: self, attribute: .Height)}
    
    func layoutCenterX()    -> LayoutAttribute {return LayoutAttribute(view: self, attribute: .CenterX)}
    func layoutCenterY()    -> LayoutAttribute {return LayoutAttribute(view: self, attribute: .CenterY)}
    
    func layoutBaseline()   -> LayoutAttribute {return LayoutAttribute(view: self, attribute: .Baseline)}
    
    // Adding Constraint(s)
    
    func addConstraint(relation: LayoutRelation) -> NSLayoutConstraint {
        let layoutConstraint = NSLayoutConstraint(item: relation.from.view, attribute: relation.from.attribute, relatedBy: relation.operator, toItem: relation.to.view, attribute: relation.to.attribute, multiplier: relation.multiplier, constant: relation.constant)
        layoutConstraint.priority = relation.priority
        
        self.addConstraint(layoutConstraint)
        
        return layoutConstraint
    }
    
    func addConstraints(constraints: Array<LayoutRelation>) -> Array<NSLayoutConstraint> {
        var result: Array<NSLayoutConstraint> = []
        
        for relation in constraints {
            result.append(addConstraint(relation))
        }
        
        return result
    }
}

func example() {
    var v1: NSView = NSView(frame: NSRect.zeroRect)
    var v2: NSView = NSView(frame: NSRect.zeroRect)
        
    v2.addSubview(v1)
    
    v2.addConstraints([
        v1.layoutTop() == v2.layoutTop() && .constant(10) && .priority(750),
        v1.layoutBottom() == v2.layoutBottom(),
        v1.layoutLeading()  == v2.layoutLeading(),
        v1.layoutTrailing() == v2.layoutTrailing()
        ])
}
