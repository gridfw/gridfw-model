###*
 * Model regestry
###
ModelRegistry = _create null

###*
 * Get registred Model
###
_define 'get', (modelName)-> ModelRegistry[modelName]

###*
 * Create new Model from schema
 * @param {string} options.name - Model name, case insensitive
 * @param {plain object} options.schema - Model schema
 * @optional @param {plain object} options.static - static properties
 * @optional @param {boolean} options.setters - create setters (.setAttr -> .attr) @default true
 * @optional @param {boolean} options.getters - create getters (.getAttr -> .attr) @default false
###
_define 'from', (options)->
	throw new Error "Illegal arguments" unless arguments.length is 1 and typeof options is 'object' and options

	# check the name of the model
	throw new Error "options.name expected string" unless typeof options.name is 'string'
	options.name = options.name.toLowerCase()

	# check and compile schema
	throw new Error "Invalid options.schema" unless typeof options.schema is 'object' and options.schema
	schema = _compileSchema schema

	# Create Model
	model = (instance)->
		# check for "new" operator
		if `new.target`
			throw new Error "Remove arguments or [new] operator" if arguments.length
			return
		# return new instance if no argument
		return _create modelProto unless arguments.length
		# throws error if illegal arguments
		throw new Error "Illegal arguments" if arguments.length isnt 1
		throw new Error "Illegal instance" unless typeof instance is 'object' and instance
		# convert Object
		_convertToModel instance, model
		# return instance
		instance
	# set model name
	_defineProperties model, name: value: options.name
	_setPrototypeOf model, ModelStatics
	# model prototype
	modelProto = model.prototype = _create ModelPrototype

###*
 * Convert object to a type model
###
_convertToModel = (instance, model)->
	schema	= model[SCHEMA]
	errors	= [] # store convert errors
	# check for generating function
	generator = model
	if TYPE_ATTR of instance
		generator = ModelRegistry[instance[TYPE_ATTR]]
		throw new Error "Unknown model: #{instance[TYPE_ATTR]}" unless generator
		throw new Error "Model [#{generator}] do not extends [#{model}]" unless generator is model or generator.prototype instanceof model
	# seek inside instance
	_seekSchema instance, schema, (ele, subSchema)->
		# set schema to this instance
		ele[SCHEMA] = subSchema
		# set prototype
		_setPrototypeOf ele, subSchema[<%= SCHEMA.proto %>]
		# if object is enextensible, remove extra attributes
		# go through attributes
		i = <%= SCHEMA.sub %>
		len = subSchema.length
		while i < len
			# load data
			attrName = subSchema[i]
			attrCheck= subSchema[++i]
			attrConvert= subSchema[++i]
			attrSubSchema= subSchema[++i]
			++i
			# check for attribute
			continue unless _owns ele, attrName
			obj = ele[attrName]
			try
				# check / convert
				unless attrCheck obj
					obj = ele[attrName] = attrConvert obj
			catch e
				delete ele[attrName]
				errors.push
					error: e
					path:	

			