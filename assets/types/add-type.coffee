###*
 * This Map contains all supported types
###
_ModelTypes = Object.create null

###*
 * Add / override Model types
###
_define 'type', (options)->
	throw new Error 'Illegal Arguments' if arguments.length isnt 1 or typeof options isnt 'object' or not options
	throw new Error 'Type name is required' unless options.name

	# Type name
	name = options.name
	name = name.name if typeof name is 'function'
	throw new Error "Illegal name: #{options.name}" unless typeof name is 'string'
	throw new Error "Invalid type name: #{name}. must match ^[A-Z][a-zA-Z0-9_-]$" unless /^[A-Z][a-zA-Z0-9_-]$/.test name

	# get name
	typeDef = _ModelTypes[name] ?= Object.create null