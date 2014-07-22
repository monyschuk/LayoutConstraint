//
//  Autolayout.swift
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
    var view: LayoutView?
    var attribute: NSLayoutAttribute
}

struct LayoutRelation {
    init(from: LayoutAttribute, operator: NSLayoutRelation, to: LayoutAttribute) {
        self.to = to
        self.from = from
        self.operator = operator
    }
    
    var from, to: LayoutAttribute
    var operator: NSLayoutRelation
    
    // optional
    
    var constant = 0.0
    var multiplier = 1.0
    var priority :LayoutPriority = 1000
    
    var layoutConstraint: NSLayoutConstraint {
        let layoutConstraint = NSLayoutConstraint(
            item:       self.from.view,
            attribute:  self.from.attribute,
            
            relatedBy:  self.operator,
            
            toItem:     self.to.view,
            attribute:  self.to.attribute,
            
            multiplier: CGFloat(self.multiplier),
            constant:   CGFloat(self.constant))
        
        layoutConstraint.priority = self.priority

        return layoutConstraint
    }
    
}

// Attribute-Attribute relations
@infix func ==(lhs: LayoutAttribute, rhs: LayoutAttribute) -> LayoutRelation {
    return LayoutRelation(from: lhs, operator: .Equal, to: rhs)
}
@infix func <=(lhs: LayoutAttribute, rhs: LayoutAttribute) -> LayoutRelation {
    return LayoutRelation(from: lhs, operator: .LessThanOrEqual, to: rhs)
}
@infix func >=(lhs: LayoutAttribute, rhs: LayoutAttribute) -> LayoutRelation {
    return LayoutRelation(from: lhs, operator: .GreaterThanOrEqual, to: rhs)
}

// Attribute-Constant relations
@infix func ==(lhs: LayoutAttribute, rhs: Double) -> LayoutRelation {
    var to = LayoutAttribute(view: nil, attribute: .NotAnAttribute)
    var relation = LayoutRelation(from: lhs, operator: .Equal, to: to)
    relation.constant = rhs
    return relation
}
@infix func <=(lhs: LayoutAttribute, rhs: Double) -> LayoutRelation {
    var to = LayoutAttribute(view: nil, attribute: .NotAnAttribute)
    var relation = LayoutRelation(from: lhs, operator: .LessThanOrEqual, to: to)
    relation.constant = rhs
    return relation
}
@infix func >=(lhs: LayoutAttribute, rhs: Double) -> LayoutRelation {
    var to = LayoutAttribute(view: nil, attribute: .NotAnAttribute)
    var relation = LayoutRelation(from: lhs, operator: .GreaterThanOrEqual, to: to)
    relation.constant = rhs
    return relation
}

@infix func ==(lhs: LayoutAttribute, rhs: Int) -> LayoutRelation {
    var to = LayoutAttribute(view: nil, attribute: .NotAnAttribute)
    var relation = LayoutRelation(from: lhs, operator: .Equal, to: to)
    relation.constant = Double(rhs)
    return relation
}
@infix func <=(lhs: LayoutAttribute, rhs: Int) -> LayoutRelation {
    var to = LayoutAttribute(view: nil, attribute: .NotAnAttribute)
    var relation = LayoutRelation(from: lhs, operator: .LessThanOrEqual, to: to)
    relation.constant = Double(rhs)
    return relation
}
@infix func >=(lhs: LayoutAttribute, rhs: Int) -> LayoutRelation {
    var to = LayoutAttribute(view: nil, attribute: .NotAnAttribute)
    var relation = LayoutRelation(from: lhs, operator: .GreaterThanOrEqual, to: to)
    relation.constant = Double(rhs)
    return relation
}


enum LayoutOption {
    case constant(Double), multiplier(Double), priority(LayoutPriority)
}

@infix func &&(var lhs: LayoutRelation, rhs: LayoutOption) -> LayoutRelation {
    switch rhs {
    case let .priority(value):      lhs.priority = value
    case let .constant(value):      lhs.constant = value
    case let .multiplier(value):    lhs.multiplier = value
    }
    return lhs
}


// An extension to NSView and UIView allowing constraints to be specified in a compact,
// descriptive format:
//
// let v1 = NSView(frame: NSRect.zeroRect)
// let v2 = NSView(frame: NSRect.zeroRect)
//
// v1.addSubview(v2)
//
// v1.addConstraints([
//  v1.layoutLeft == v2.layoutLeft,
//  v1.layoutRight == v2.layoutRight && .priority(750),
//  v1.layoutCenterY == v2.layoutCenterY && .constant(-10.0)
// ])
//
// v2.addConstraint(v2.layoutHeight == 14)
//

extension LayoutView {
    
    var layoutTop:      LayoutAttribute {return LayoutAttribute(view: self, attribute: .Top)}
    var layoutLeft:     LayoutAttribute {return LayoutAttribute(view: self, attribute: .Left)}
    var layoutRight:    LayoutAttribute {return LayoutAttribute(view: self, attribute: .Right)}
    var layoutBottom:   LayoutAttribute {return LayoutAttribute(view: self, attribute: .Bottom)}
    
    var layoutLeading:  LayoutAttribute {return LayoutAttribute(view: self, attribute: .Leading)}
    var layoutTrailing: LayoutAttribute {return LayoutAttribute(view: self, attribute: .Trailing)}
    
    var layoutWidth:    LayoutAttribute {return LayoutAttribute(view: self, attribute: .Width)}
    var layoutHeight:   LayoutAttribute {return LayoutAttribute(view: self, attribute: .Height)}
    
    var layoutCenterX:  LayoutAttribute {return LayoutAttribute(view: self, attribute: .CenterX)}
    var layoutCenterY:  LayoutAttribute {return LayoutAttribute(view: self, attribute: .CenterY)}
    
    var layoutBaseline: LayoutAttribute {return LayoutAttribute(view: self, attribute: .Baseline)}
    
    // Adding Constraint(s)
    
    func addConstraint(relation: LayoutRelation) -> NSLayoutConstraint {
        
        let layoutConstraint = relation.layoutConstraint
        self.addConstraint(layoutConstraint)
        return layoutConstraint
    }
    
    func addConstraints(constraints: [LayoutRelation]) -> [NSLayoutConstraint] {
        
        var result: [NSLayoutConstraint] = []
        for relation in constraints {
            result.append(addConstraint(relation))
        }
        return result
    }
}

// Layouts

protocol Layout {
    typealias ViewType
    
    var views: [ViewType] {get}
    var constraints: [NSLayoutConstraint] {get}
}

// Common Layouts:

// ListLayout represents a vertical or horizontal list of views within a parent view - eg.
// horizontalButtonLayout = ListLayout(views: buttons, container: buttonContainer, orientation: .Horizontal, trailingRelationFn: ==)

typealias LayoutRelationFn = (LayoutAttribute, LayoutAttribute) -> LayoutRelation

class ListLayout<T: LayoutView>: Layout {
    
    var container: LayoutView
    var orientation: NSLayoutConstraintOrientation
    var trailingRelationFn: LayoutRelationFn!
    
    init(views: [T], container: LayoutView, orientation: NSLayoutConstraintOrientation, trailingRelationFn: LayoutRelationFn! = nil) {
        self.views              = views
        self.container          = container
        self.orientation        = orientation
        self.trailingRelationFn = trailingRelationFn

        // layout builder
        var prev: T! = nil
        
        var axisRelations = [LayoutRelation]()
        var offAxisRelations = [LayoutRelation]()
        
        for v in self.views {
            if v.superview != self.container {
                self.container.addSubview(v)
            }
            
            switch self.orientation {
            case .Vertical:
                axisRelations += (v.layoutTop == (prev ? prev.layoutBottom : v.superview.layoutTop)) && .priority(750)
                offAxisRelations += [v.layoutLeft == v.superview.layoutLeft && .priority(750), v.layoutRight == v.superview.layoutRight && .priority(750)]
                
            case .Horizontal:
                axisRelations += (v.layoutLeading == (prev ? prev.layoutTrailing : v.superview.layoutLeading)) && .priority(750)
                offAxisRelations += [v.layoutTop == v.superview.layoutTop && .priority(750), v.layoutBottom == v.superview.layoutBottom && .priority(750)]
            }
            
            prev = v
        }
        
        if prev {
            if self.trailingRelationFn {
                switch self.orientation {
                case .Vertical:
                    axisRelations += self.trailingRelationFn(prev.layoutBottom, prev.superview.layoutBottom) && .priority(750)
                case .Horizontal:
                    axisRelations += self.trailingRelationFn(prev.layoutTrailing, prev.superview.layoutTrailing) && .priority(750)
                }
            }
        }

        self.axisConstraints    = axisRelations.map {$0.layoutConstraint}
        self.offAxisConstraints = offAxisRelations.map {$0.layoutConstraint}
    }
    
    // Layout Protocol
    var views: [T]
    var constraints: [NSLayoutConstraint] { return self.axisConstraints + self.offAxisConstraints }

    // Layout Protocol Support
    var axisConstraints: [NSLayoutConstraint] // constraints along self.orientation
    var offAxisConstraints: [NSLayoutConstraint] // constraints perpendicular to self.orientation
}
