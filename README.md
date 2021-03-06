LayoutConstraint
================

Expressive NSLayoutConstraints with Swift, inspired by Jonathan 'Wolf' Rentzsch's AutoLayoutShorthand: https://github.com/rentzsch/AutoLayoutShorthand

Usage
-----

Given two views, v1 and v2:

	let v1 = NSView(frame: NSRect.zeroRect)
	let v2 = NSView(frame: NSRect.zeroRect)
	v1.addSubview(v2)

Add constraints in shorthand form like so:

	v1.addConstraints([
		v1.layoutCenterY == v2.layoutCenterY,
		v1.layoutLeading == v2.layoutLeading,
		v1.layoutTrailing == v2.layoutTrailing
	])
	v2.addConstraint(v2.layoutHeight == 12)
    
You can optionally specify constants, multipliers, and priority inline with your definition:

	v1.addConstraints([
		v1.layoutTop == v2.layoutTop && .constant(10) && .priority(750),
		v1.layoutBottom == v2.layoutBottom,
		v1.layoutLeading == v2.layoutLeading,
		v1.layoutTrailing == v2.layoutTrailing
	])

Layout Expression Grammar
-------------------------

	relation-expression :=
		layout-attribute ( '==' | '<=' | '>=' ) value 
		| layout-attribute ( '==' | '<=' | '>=' ) layout-attribute
	
	option-expression := 
		.priority(value) 
		| .constant(value) 
		| .multiplier(value)
	
	layout-expression := 
		relation-expression 
		| layout-expression '&&' option-expression

License
-------

MIT license - please feel free to use this as you like!
