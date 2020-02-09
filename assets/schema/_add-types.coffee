###*
 * Basic type
###
_Mixed=
	name: 'Mixed'

###*
 * Add new types to the schema
 * Model.addType('Name', descriptor)
 * Model.addType([names], descriptor)
###
_defineProperty Model, 'addType', value: (name, descriptor)->
	throw new Error "Unimplemented"
	this # chain