###*
 * Add new types to the schema
 * Model.addType({
 * 		TypeName:
 * 			fx: optional, when an fx is representing the type, example: Number
 * 			alt: [Alternative names]
 * 			d: -> this.check(checkFx).convert(convertFx)
 * 			asserts: {} List of possible assertions
 * 			
 * 			
 * })
###
_defineProperty Model, 'addTypes', value: (descriptors)->
	return