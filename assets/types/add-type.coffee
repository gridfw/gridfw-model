###*
 * This Map contains all supported types
###
_ModelTypes = Object.create null

###*
 * Add / override Model types
 * @param {string} options.name - name of the type
 * @param {function} options.check - check the type, returns boolean or throws exception
 * @param {function} options.convert - convert logic of the value, returns new value or throws exception (when parsing JSON or DB)
 * @optional @param {function} options.assert - assertion on the value
 * @optional @param {function} options.pipe - operation to do on the value when first add
 * @optional @param {function} options.toJSON - returns value of JSON representation
 * @optional @param {function} opitons.toDB - returns value to be stored on the database
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
	typeDef = _ModelTypes[name]
	unless typeDef # new type
		throw new Error "Option [check] is required function" unless typeof options.check is 'function'
		throw new Error "[#{name}] is a reserved name" if typeDef of Model
		typeDef = _ModelTypes[name] = Object.create null
		# define descriptor
		_defineDescriptor name, get: ->
			@[<% attrDescriptor.type %>] = typeDef
			return

	# set check
	for k in ['check', 'convert', 'assert', 'pipe', 'toJSON', 'toDB']
		typeDef[k] = options[k] if options[k]
	# chain
	this