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
_defineProperty Model, 'type', value:(options)->
	throw new Error 'Illegal Arguments' if arguments.length isnt 1 or typeof options isnt 'object' or not options
	throw new Error 'Type name is required' unless options.name

	# Type name
	typeKey = name = options.name
	name = name.name if typeof name is 'function'
	throw new Error "Illegal name: #{options.name}" unless typeof name is 'string'
	throw new Error "Invalid type name: #{name}. must match ^[A-Z][a-zA-Z0-9_-]+$" unless /^[A-Z][a-zA-Z0-9_-]+$/.test name

	# get name
	typeDef = _ModelTypes[name]
	if typeDef
		# throw error if two different functions with some name
		throw new Error "Function with same name [#{name}] already set. Please choose functions with different names" unless typeDef.name is typeKey
	else # new type
		# extends
		if 'extends' of options
			ext = options.extends
			if typeof ext is 'function'
				ext = ext.name 
			else unless typeof ext is 'string'
				throw new Error "Illegal extend"
			typeDef = _ModelTypes[ext]
			throw new Error "Could not found parent type: #{ext}" unless typeDef
			typeDef = _clone typeDef
		else
			typeDef = _create null
		_ModelTypes[name] = typeDef
		typeDef.name = typeKey
		# check
		throw new Error "Option [check] is required function" unless (typeof options.check is 'function') or ('check' of typeDef)
		throw new Error "[#{name}] is a reserved name" if name of Model
		# define descriptor
		_defineDescriptor
			get:
				[name]: ->
					@type = typeDef
					# define asserts
					if typeDef.assert
						assertObj = @assertObj ?= _create null
						for k,v of typeDef.assert
							assertObj[k] = v unless _owns assertObj, k
					# define pipe
					(@pipe ?= []).push typeDef.pipe if typeof typeDef.pipe is 'function'
					# define toJSON
					@toJSON ?= typeDef.toJSON if typeof typeDef.toJSON is 'function'
					# define toDB
					@toDB ?= typeDef.toDB if typeof typeDef.toDB is 'function'
					return
	# set check
	for k in ['check', 'convert', 'assert', 'assertions', 'pipe', 'toJSON', 'toDB']
		typeDef[k] = options[k] if options[k]
	# chain
	this
###*
 * define type compiler
###
_defineDescriptor
	compile: (attr, schema, proto, attrPos)->
		type = @type
		if type
			schema[attrPos + <%= SCHEMA.attrType %>] = type
			schema[attrPos + <%= SCHEMA.attrCheck %>] = type.check
			schema[attrPos + <%= SCHEMA.attrConvert %>] = type.convert
		return