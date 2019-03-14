###*
 * Get registred Model
###
_defineProperty ModelP, 'get', value: (modelName)->
	throw new Error 'Expected string' unless typeof modelName is 'string'
	@all[modelName.toLowerCase()]

###*
 * Create new Model from schema
 * @param {string} options.name - Model name, case insensitive
 * @param {plain object} options.schema - Model schema
 * @optional @param {plain object} options.static - static properties
 * @optional @param {boolean} options.setters - create setters (.setAttr -> .attr) @default true
 * @optional @param {boolean} options.getters - create getters (.getAttr -> .attr) @default false
###
_defineProperty ModelP, 'from', value: (options)->
	<%= assertArgTypes('Model.from', 'plain object') %>

	# check the name of the model
	throw new Error "Model name expected string" unless typeof options.name is 'string'
	modelName = options.name.toLowerCase()
	throw new Error "Model alreay set: #{modelName}" if @all.hasOwnProperty modelName 

	# check and compile schema
	schema= options.schema
	throw new Error "Invalid options.schema" unless typeof schema is 'object' and schema
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
				return _create modelProto
			when 1
				return _fastInstanceConvert.call model, instance
			else
				throw new Error "Illegal arguments"
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
	_defineProperty @all, modelName,
		value: model
		enumerable: yes
	# return model
	model

###*
 * Override existing model
 * @param {string} options.name - Model name, case insensitive
 * @param {plain object} options.schema - Model schema
 * @optional @param {plain object} options.static - static properties
###
_defineProperty ModelP, 'override', value: (options)->
	throw new Error "Illegal arguments" unless arguments.length is 1 and typeof options is 'object' and options
	# check the name of the model
	throw new Error "Model name is required" unless 'name' of options
	throw new Error "Model name expected string" unless typeof options.name is 'string'
	modelName = options.name.toLowerCase()
	throw new Error "Unknown Model: #{modelName}" unless @all.hasOwnProperty modelName
	model = @all[modelName]
	# override schema
	if 'schema' of options
		errors = _compileSchema options.schema, model[SCHEMA]
		throw new SchemaError "Schema contains #{errors.length} errors.", errors if errors.length
	# override static properties
	if 'static' of options
		_defineProperties model, Object.getOwnPropertyDescriptors options.static
	# chain
	this