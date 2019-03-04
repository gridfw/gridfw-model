###*
 * Get registred Model
###
_defineProperty Model, 'get', value: (modelName)-> @all[modelName]

###*
 * Create new Model from schema
 * @param {string} options.name - Model name, case insensitive
 * @param {plain object} options.schema - Model schema
 * @optional @param {plain object} options.static - static properties
 * @optional @param {boolean} options.setters - create setters (.setAttr -> .attr) @default true
 * @optional @param {boolean} options.getters - create getters (.getAttr -> .attr) @default false
###
_defineProperty Model, 'from', value: (options)->
	throw new Error "Illegal arguments" unless arguments.length is 1 and typeof options is 'object' and options

	# check the name of the model
	throw new Error "Model name is required" unless 'name' of options
	throw new Error "Model name expected string" unless typeof options.name is 'string'
	modelName = options.name.toLowerCase()
	throw new Error "Model alreay set: #{modelName}" if modelName of @all

	# check and compile schema
	throw new Error "Invalid options.schema" unless typeof options.schema is 'object' and options.schema
	compiledSchema = []
	# extensibility
	compiledSchema[<%= SCHEMA.extensible %>] = if options.schema[DESCRIPTOR]?.extensible then on else off
	# compile schema
	errors = _compileSchema options.schema, compiledSchema
	throw new SchemaError "Schema contains #{errors.length} errors.", errors if errors.length

	# Create Model
	# model prototype
	switch compiledSchema[<%= SCHEMA.schemaType %>]
		when <%= SCHEMA.OBJECT %>
			modelProto= _docObjProto
		when <%= SCHEMA.LIST %>
			modelProto= _docArrProto
		else
			throw new Error 'Unsupported schema'

	_setPrototypeOf compiledSchema[<%= SCHEMA.proto %>], modelProto
	modelProto = compiledSchema[<%= SCHEMA.proto %>]
	# Use Model.fromJSON or Model.fromDB to performe recusive convertion
	model = (instance)->
		# check for "new" operator
		if `new.target`
			throw new Error "Remove arguments or [new] operator" if arguments.length
			return
		# convert instance
		switch arguments.length
			when 0
				instance = _create modelProto
			when 1
				throw new Error "Illegal instance" unless typeof instance is 'object' and instance
				# convert Object
				_setPrototypeOf instance, modelProto
			else
				throw new Error "Illegal arguments"
		# return instance
		instance
	# set proto
	model.prototype = modelProto
	# add schema
	model[SCHEMA] = compiledSchema
	# set model name
	_defineProperties model,
		name: value: modelName
		Model: value: this
	_setPrototypeOf model, ModelStatics
	# add static attributes
	if 'static' of options
		_defineProperties model, Object.getOwnPropertyDescriptors options.static
	# add to registry
	@all[modelName] = model
	# return model
	model

###*
 * Override existing model
 * @param {string} options.name - Model name, case insensitive
 * @param {plain object} options.schema - Model schema
 * @optional @param {plain object} options.static - static properties
###
_defineProperty Model, 'override', value: (options)->
	throw new Error "Illegal arguments" unless arguments.length is 1 and typeof options is 'object' and options
	# check the name of the model
	throw new Error "Model name is required" unless 'name' of options
	throw new Error "Model name expected string" unless typeof options.name is 'string'
	modelName = options.name.toLowerCase()
	model = @all[modelName]
	throw new Error "Unknown Model: #{modelName}" unless model
	# override schema
	if 'schema' of options
		errors = _compileSchema options.schema, model[SCHEMA]
		throw new SchemaError "Schema contains #{errors.length} errors.", errors if errors.length
	# override static properties
	if 'static' of options
		_defineProperties model, Object.getOwnPropertyDescriptors options.static
	# chain
	this