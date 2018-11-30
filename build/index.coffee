do ->
	###*
	 * Model
	###
	
	
	# String
	STRING_MAX = 3000 # String max length
	HTML_MAX_LENGTH= 10000 # HTML max length
	
	PASSWD_MIN	= 8 # password min length
	PASSWD_MAX	= 100 # password max length
	
	URL_MAX_LENGTH= 3000 # URL max length
	DATA_URL_MEX_LENGTH = 30000 # Data URL max length
	
	# schema attribute descriptor count
	SCHEMA_COUNT = 5 # @see schema/schema.tempate.js for more info
	
	# hex check
	HEX_CHECK	= /^[0-9a-f]$/i
	# Email check
	EMAIL_CHECK = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
	
	
	# symbols
	SCHEMA = Symbol 'Model schema'
	DESCRIPTOR = Symbol 'Descriptor'
	TYPE_ATTR = '_type' # extra attr inside object, refers its Model
	
	# methods
	_create = Object.create
	_setPrototypeOf= Object.setPrototypeOf
	_defineProperties= Object.defineProperties
	_defineProperty= Object.defineProperty
	_has = Reflect.has
	_owns= (obj, property)-> Object.hasOwnProperty.call obj, property
	
	
	# Array
	_ArrayPush = Array::push
	
	
	# check
	_isPlainObject = (obj)-> obj and typeof obj is 'object' and not Array.isArray obj
	
	# clone
	_clone = (obj)-> Object.assign {}, obj
	
	# json pretty
	_jsonPretty = (obj)->
		_prettyJSON = (k,v) ->
			if typeof v is 'function'
				v= "[FUNCTION #{v.name}]"
			else if typeof v is 'symbol'
				v= "[SYMBOL #{v}]"
			else if v instanceof Error
				v =
					message: v.message
					stack: v.stack.split("\n")[0..2]
			v
		JSON.stringify obj, _prettyJSON, "\t"
	_schemaDescriptor = _create null
	Model = _create _schemaDescriptor

	# basic error log
	Model.logError = console.error.bind console

	

	# main
	###*
	 * Main model
	###
	# Model = (instance)->
	# 	# new generic instance
	# 	if `new.target`
	# 		# could not use "new" operator and arguments in the same time
	# 		throw new Error "Remove arguments or [new] operator" if arguments.length
	# 		return
	# 	# use withoud "new" operator
	# 	else unless arguments.length
	# 		instance = Object.create Model.prototype
	# 	else if arguments.length is 1 and typeof instance is 'object' and instance
	# 		Object.setPrototypeOf instance, Model.prototype
	# 	else
	# 		throw new Error "Illegal arguments"
	# 	return instance
	# prototype
	ModelPrototype = _create null
	# static protoperties
	ModelStatics = _create null
	### Add symbols ###
	_defineProperties Model,
		SCHEMA: value: SCHEMA # link object to it's schema
		TYPE_ATTR: value: TYPE_ATTR
	
	
	###*
	
	
	 * Commun array prototype
	
	
	###
	
	
	_arrayProto = _create Array.prototype,
	
	
		push: value: ->
	
	
			values = Array.from arguments
	
	
			# convert all types
	
	
			# for value in values
	
	
	
	
	
			# push
	
	
			_ArrayPush.apply this, values
	
	
	
	
	
	
	
	
	### Common plain object prototype ###
	
	
	_plainObjPrototype = {}
	###*
	 * Model regestry
	###
	ModelRegistry = _create null
	
	###*
	 * Get registred Model
	###
	_defineProperty Model, 'get', value: (modelName)-> ModelRegistry[modelName]
	
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
		throw new Error "Model alreay set: #{modelName}" if modelName of ModelRegistry
	
		# check and compile schema
		throw new Error "Invalid options.schema" unless typeof options.schema is 'object' and options.schema
		errors = []
		schema = _compileSchema options.schema,errors
		throw new Error "Schema contains #{errors.length} errors.\n #{_jsonPretty errors}" if errors.length
	
		# Create Model
		# Use Model.fromJSON or Model.fromDB to performe recusive convertion
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
			_setPrototypeOf instance, modelProto
			# return instance
			instance
		# add schema
		model[SCHEMA] = schema
		# set model name
		_defineProperties model,name: value: modelName
		_setPrototypeOf model, ModelStatics
		# add static attributes
		if 'static' of options
			_defineProperties model, Object.getOwnPropertyDescriptors options.static
		# model prototype
		modelProto = model.prototype = _create ModelPrototype
		# add to registry
		ModelRegistry[modelName] = model
		# return model
		model
	
	
	###*
	 * Convert instance from database
	 * This will not performe any validation
	 * Will do any required convertion
	###
	_defineProperties ModelStatics,
		###*
		 * Faster model convertion
		 * no validation will be performed
		 * Convert an instance from DB or any trusted source
		 * Any illegal attribute value will just be escaped
		 * @param  {[type]} instance [description]
		 * @return {[type]}          [description]
		###
		fromDB: value: _fastInstanceConvert
		###*
		 * From unstrusted source
		 * will performe validations
		 * @type {[type]}
		###
		fromJSON: value: _instanceConvert
	
	
	###*
	 * Fast object convertion
	 * from DB or any trusted source
	 * No validation will be performed
	 * Do not use recursivity for performace purpos and 
	 * to avoid possible stack overflow
	###
	_fastInstanceConvert = (instance, model)->
		throw new Error "Illegal arguments" unless typeof instance is 'object' and instance
		# get model
		switch arguments.length
			when 1
				model = this
			when 2
			else
				throw new Error "Illegal arguments"
		# if generator is sub-Model
		if TYPE_ATTR of instance
			model = ModelRegistry[instance[TYPE_ATTR]]
			throw new Error "Unknown model: #{instance[TYPE_ATTR]}" unless model
			# Canceled test below for performance purpose
			# throw new Error "Model [#{generator}] do not extends [#{model}]" unless generator is model or generator.prototype instanceof model
		# schema
		schema = model[SCHEMA]
		# seek
		seekQueu = [instance, schema]
		seekQueuIndex = 0
		while seekQueuIndex < seekQueu.length
			# load args
			instance= seekQueu[seekQueuIndex]
			schema	= seekQueu[++seekQueuIndex]
			++seekQueuIndex
			# convert Object
			obj[SCHEMA] = schema
			_setPrototypeOf obj, schema[1]
			# go through attributes
			i = 9
			len = schema.length
			while i < len
				# load attr info
				attrName = schema[i]
				attrCheck= schema[++i]
				attrConvert= schema[++i]
				attrSchema= schema[++i]
				++i
				# check for attribute
				continue unless _owns obj, attrName
				attrObj = obj[attrName]
				# continue if is null or undefined
				if attrObj in [undefined, null]
					delete obj[attrName]
					continue
				# convert type
				try
					# check / convert
					unless attrCheck attrObj
						attrObj = obj[attrName] = attrConvert attrObj
					# if is plain object, add to next subobject to check
					if typeof attrObj is 'object' and attrObj
						seekQueu.push attrObj, attrSchema
				catch e
					delete ele[attrName]
					Model.logError 'DB CONV', e
		# return instance
		instance
	
	
	###*
	 * Convert instance to Model type
	 * used when data is from untrusted source
	 * will do validation and any required clean
	 * example: JSON from client
	###
	_instanceConvert = (instance, model)->
		throw new Error "Illegal arguments" unless typeof instance is 'object' and instance
		# get model
		switch arguments.length
			when 1
				model = this
			when 2
			else
				throw new Error "Illegal arguments"
		# if generator is sub-Model
		if TYPE_ATTR of instance
			model = ModelRegistry[instance[TYPE_ATTR]]
			throw new Error "Unknown model: #{instance[TYPE_ATTR]}" unless model
			# Canceled test below for performance purpose
			# throw new Error "Model [#{model}] do not extends [#{model}]" unless model is model or model.prototype instanceof model
		# schema
		schema = model[SCHEMA]
		# seek
		seekQueu = [instance, schema]
		seekQueuIndex = 0
		while seekQueuIndex < seekQueu.length
			# load args
			instance= seekQueu[seekQueuIndex]
			schema	= seekQueu[++seekQueuIndex]
			++seekQueuIndex
			# convert Object
			obj[SCHEMA] = schema
			_setPrototypeOf obj, schema[1]
			# go through attributes
			i = 9
			len = schema.length
			while i < len
				# load attr info
				attrName = schema[i]
				attrCheck= schema[i+1]
				attrConvert= schema[i+2]
				attrSchema= schema[i+3]
				i += SCHEMA_COUNT
				# check for attribute
				continue unless _owns obj, attrName
				attrObj = obj[attrName]
				# continue if is null or undefined
				if attrObj in [undefined, null]
					delete obj[attrName]
					continue
				# convert type
				try
					# check / convert
					unless attrCheck attrObj
						attrObj = obj[attrName] = attrConvert attrObj
					# if is plain object, add to next subobject to check
					if typeof attrObj is 'object' and attrObj
						seekQueu.push attrObj, attrSchema
				catch e
					delete ele[attrName]
					Model.logError 'DB CONV', e
		# return instance
		instance
	

	# schema
	
	# includes
	
	###*
	 * Define descriptor
	 * @param {object} options.get	- descriptors using GET method
	 * @param {object} options.fx	- descriptors using functions
	 * @param {function} options.compile	- compilation of result
	###
	_descriptorCompilers = [] # set of descriptor compilers
	_defineDescriptor= (options)->
		# getters
		if 'get' of options
			for k,v of options.get
				_defineProperty _schemaDescriptor, k, get: _defineDescriptorWrapper v
		# functions
		if 'fx' of options
			for k,v of options.fx
				_defineProperty _schemaDescriptor, k, value: _defineDescriptorWrapper v
		# compile
		if 'compile' of options
			_descriptorCompilers.push options.compile
		return
	### wrapper ###
	_defaultDescriptor = ->
		# create descriptor
		desc = _create null
		# return schema descriptor
		obj = _create _schemaDescriptor,
			[DESCRIPTOR]: value: desc
		desc._ = obj
		return obj
	_defineDescriptorWrapper = (fx) ->
		->
			desc = if this is Model then _defaultDescriptor() else this
			# exec fx
			fx.apply desc[DESCRIPTOR], arguments
			# chain
			desc
	
		
	
	### JSON cleaner ###
	_toJSONCleaner = (obj, attrToRemove)->
		result = _create null
		for k,v of obj
			result[k] = v unless k in attrToRemove
		_setPrototypeOf result, Object.getPrototypeOf obj
		return result
	###*
	 * JSON ignore
	###
	_defineDescriptor
		# JSON getters
		get:
			jsonIgnore: -> @jsonIgnore = 3 # ignore json, 3 = 11b = ignoreSerialize | ignoreParse
			jsonIgnoreStringify: -> @jsonIgnore = 1 # ignore when serializing: 1= 1b
			jsonIgnoreParse: -> @jsonIgnore = 2 # ignore when parsing: 2 = 10b
			jsonEnable: -> @jsonIgnore = 0 # include this attribute with JSON, @default
		# Compile Prototype and schema
		compile: (attr, schema, proto)->
			jsonIgnore = @jsonIgnore
			# do not serialize attribute
			if jsonIgnore & 1
				ignoreJSONAttr = schema[3]
				if ignoreJSONAttr
					ignoreJSONAttr.push attr
				else
					ignoreJSONAttr = schema[3] = [attr]
					_defineProperties proto, toJSON: -> _toJSONCleaner this, ignoreJSONAttr
			# ignore when parsing
			if jsonIgnore & 2
				#TODO add this to "model.fromJSON"
				(schema[4] ?= []).push attr
			return
	###*
	 * Virtual methods
	###
	_defineDescriptor
		get:
			virtual: -> @virtual = on
			transient: -> @virtual = on
			persist: -> @virtual = off
		compile: (attr, schema, proto)->
			if @virtual
				virtualAttr = schema[6]
				if virtualAttr
					virtualAttr.push attr
				else
					virtualAttr = schema[6] = [attr]
					# implemented for each db engine
					# _defineProperties proto, toDB: -> _toJSONCleaner this, virtualAttr
			return
	
	###*
	 * Set attribute as required
	###
	_defineDescriptor
		get:
			required: -> @required = on
			optional: -> @required = off
		compile: (attr, schema, proto)->
			if @required
				(schema[SCHEMA.required] ?= []).push attr
			return
	
	###*
	 * Set an object as freezed or extensible
	###
	_defineDescriptor
		get:
			freeze: -> @extensible = off
			extensible: -> @extensible = on
		# compile: (attr, schema, proto)->
		# 	#TODO
		# 	schema[SCHEMA.extensible] = @extensible isnt off
		# 	return
	
	###*
	 * Default value
	 * getters / setters
	 * .default(8).default('static value').default(true) # default static value
	 * .default(window) # static value
	 * .default({}) # be careful !! some object will set for all instances
	 * .default(=>{}) # create new object for each instance once.
	 * .default(-> this.attr ) # generating default value from function (will be called once)
	 * .default(Date.now) # generating default value from function (will be called once)
	 *
	 * .get(-> value)
	 * .set(-> value)
	###
	_defineDescriptor
		fx:
			default: (value)->
				throw new Error 'Illegal arguments' unless arguments.length is 1
				# when default value is function, wrap it inside getter
				if typeof value is 'function'
					@getter = ->
						vl = deflt.call this
						_defineProperty this, attr, value: vl
						return vl
				# otherwise, it static value (be careful for objects!)
				else
					@default = value
				return
			getter: (fx)->
				throw new Error "Illegal arguments" unless arguments.length is 1
				throw new Error "function expected" unless typeof fx is 'function'
				throw new Errro "Getter expects no argument" unless fx.length is 0
				@getter = fx
				return
			setter: (fx)->
				throw new Error "Illegal arguments" unless arguments.length is 1
				throw new Error "function expected" unless typeof fx is 'function'
				throw new Errro "Setter expects signature: function(value){}" unless fx.length is 1
				@setter = fx
				return
			###*
			 * Alias
			 * @example
			 * .alias('attrName')	# alias to this attribute
			 * .alias(-> getter_expr)# alias to .getter(-> getter_expr)
			###
			alias: (value)->
				throw new Error "Illegal arguments" unless arguments.length is 1
				# alias to attribute
				if typeof value is 'string'
					@getter = -> @[value]
				# getter
				else if typeof value is 'function'
					@_.getter value
				return
		compile: (attr, schema, proto)->
			if typeof @getter is 'function' or typeof @setter is 'function'
				_defineProperty proto, attr,
					get: @getter
					set: @setter
			else if _owns this, 'default'
				_defineProperty proto, attr, value: @default
			return
	
	###*
	 * Assertions
	 * Used when validating data
	 * @example
	 * .assert(true)
	 * .assert(true, 'Optional Error message')
	 * .assert((data)-> data.isTrue())
	 * .assert((data)-> throw new Error "Error message: #{data}")
	 * .assert(async (data)-> asyncOp(data))
	###
	_defineDescriptor
		fx:
			assert: (assertion, optionalMessage)->
				# assertion object
				if typeof assertion is 'object' and assertion
					throw new Error "Could not set optional message when configuring predefined assertion, use .assert(function(data){}, 'optional message') instead." if optionalMessage
					assertObj = @assertObj ?= _create null
					for k,v of assertion
						assertObj[k] = v
				else
					throw new Error "Illegal arguments" unless arguments.length in [1,2]
					throw new Error "Optional message expected string" if optionalMessage and typeof optionalMessage isnt 'string'
					# convert to function
					if typeof assertion isnt 'function'
						vl = assertion
						assertion = (data)-> data is vl
					# add to assertions
					(@asserts ?= []).push assertion, optionalMessage
				return
			# wrappers
			length: (value) ->
				throw new Error "Illegal arguments" unless arguments.length is 1
				(@assertObj ?= _create null).length = value
			min: (min)->
				throw new Error "Illegal arguments" unless arguments.length is 1
				(@assertObj ?= _create null).min = min
			max: (max)->
				throw new Error "Illegal arguments" unless arguments.length is 1
				(@assertObj ?= _create null).max = max
			between: (min, max)->
				throw new Error "Illegal arguments" unless arguments.length is 2
				assertObj = @assertObj ?= _create null
				assertObj.min = min
				assertObj.max = max
				return
			match: (regex)->
				throw new Error "Illegal arguments" unless arguments.length is 1
				(@assertObj ?= _create null).match = regex
				return
		compile: (attr, schema, proto, attrPos)->
			# add basic asserts
			if _owns this, 'assertObj'
				# get type
				type = @type
				throw new Error "No type specified to use predefined assertions. Use assert(function(data){}) instead" unless type
				typeAssertions = type.assertions
				throw new Error "No assertions predefined for type [#{type.name}]. Use assert(function(data){}) instead" unless typeAssertions
				# go through assertions
				asserts = @asserts ?= []
				# generate assertion
				assertGen = (attr, assert, value)->
					(data) -> assert data, value
				# iterations
				for k,v of @assertObj
					throw new Error "No predefined assertion [#{k}] on type [#{type.name}]" unless _owns typeAssertions, k
					# check value
					assertC = typeAssertions[k]
					assertC.check v
					# add assertion
					asserts.push assertGen(k, assertC.assert, v), null # null represents the optional error message
			# add asserts
			if _owns this, 'asserts'
				schema[attrPos + 3] = @asserts
			return
	
	### pipe ###
	_defineDescriptor
		fx:
			pipe: (fx)->
				throw new Error "Illegal arguments" unless arguments.length is 1
				throw new Error "Expected function" unless typeof fx is 'function'
				(@pipe ?= []).push fx
				return
		compile: (attr, schema, proto, attrPos)->
			if _owns this, 'pipe'
				schema[attrPos + 4] = @pipe
	
	###*
	 * toJSON / toDB
	###
	_defineDescriptor
		fx:
			toJSON: (fx)->
				throw new Error "Illegal arguments" unless arguments.length is 1
				throw new Error "Expected function" unless typeof fx is 'function'
				@toJSON = fx
				return
			toDB: (fx)->
				throw new Error "Illegal arguments" unless arguments.length is 1
				throw new Error "Expected function" unless typeof fx is 'function'
				@toDB = fx
				return
		compile: (attr, schema, proto, attrPos)->
			(schema[SCHEMA.toJSON] ?= []).push attr, @toJSON if @toJSON
			(schema[SCHEMA.toDB] ?= []).push attr, @toJSON if @toDB
			return
	
	###*
	 * Value
	 * @example
	 * .value(Number) equivalent to: Number
	 * .value(sub-schema) equivalent to: sub-schema
	 * .value(Model.Int) equivalent to: Model.Int
	 * .value(function(){}) equivalent to: function(){}
	###
	_defineDescriptor
		fx:
			value: (arg)->
				throw new Error "Illegal arguments" unless arguments.length is 1
				throw new Error 'Illegal use of "Model" keyword' if arg is Model
				throw new Error "Illegal use of nested object" if @nestedObj or @arrItem or @protoMethod
				# check if function
				if typeof arg is 'function'
					# check if registred type
					if (t = _ModelTypes[arg.name]) and t.name is arg
						arg= Model[arg.name]
					# if date.now, set it as default value
					else if arg is Date.now
						arg= Model.default arg
					# else add this function as prototype property
					else
						@protoMethod = arg
						return
				# if it is an array of objects
				else if Array.isArray arg
					arg = _arrToModelList arg
				# nested object
				else if typeof arg is 'object'
					unless _owns arg, DESCRIPTOR
						@_.Object
						@nestedObj = arg
						return
				else
					throw new Error "Illegal attribute descriptor"
				# merge
				arg = arg[DESCRIPTOR]
				for k,v of arg
					@[k] = v
				return
			compile: (attr, schema, proto, attrPos)->
				# prototype method
				if _owns this, 'protoMethod'
					_defineProperty proto, attr, value: @protoMethod
	
				else if @nestedObj
					# will be compiled, just to avoid recursivity
					throw new Error 'Illegal use of nested objects' unless @type is _ModelTypes.Object
					# create object schema
					# [schemaType, proto, extensible, ignoreJSON, ignoreParse, requiredAttributes, virtualAttributes, toJSON, toDB]
					
					objSchema = new Array 9
					# objSchema[0] = 1 # -1: means object not yeat compiled
					# objSchema[1] = _create _plainObjPrototype
					objSchema[2] = @extensible || off
					delete @extensible
	
					schema[attrPos + 5] = objSchema
				return
	
	###*
	 * List
	 * @example
	 * .list(Number)
	 * .list({sub-schema})
	 * .list(Model.Int)
	 * .list(Model.list(...))
	 * .list(Number, {prototype methods})
	 * .list Number
	 * 		sort: function(cb){}
	 * 		length: Model.getter(...).setter(...)
	###
	_defineDescriptor
		fx:
			list: (arg, prototype)->
				throw new Error "Illegal arguments" unless arguments.length in [1,2]
				throw new Error "Illegal use of list" if @nestedObj or @arrItem
				# set type as array
				@_.Array
				# check prototype
				proto = _create null
				if arguments.length is 2
					throw new Error "Illegal prototype" unless _isPlainObject prototype
					for k,v of prototype
						# getter/setter
						if v and typeof v is 'object'
							if v[DESCRIPTOR]
								v = v[DESCRIPTOR]
								# check for getter and setter only
								throw new Error "Only 'getter' and 'setter' are accepted as list prototype attribute. [#{ek}] detected." unless ek in ['_', 'getter', 'setter'] for ek, ev of v
								if v.getter or v.setter
									_defineProperty proto, k,
										get: v.getter
										set: v.setter
								else
									throw new Error "getter or setter is required"
							else
								throw new Error "Illegal list prototype attribute: #{k}, use Model.getter(...) instead"
						# reject types
						else if v is Model or (ref = _ModelTypes[v.name] and ref.name is v)
							throw new Error "Only methods, setters, getters are expected as list prototype property"
						# method or static value
						else
							_defineProperty proto, k, value: v
				_setPrototypeOf proto, _arrayProto
				@arrProto = proto
				# arg
				# predefined type
				if typeof arg is 'function'
					throw new Error 'Illegal argument' unless (t = _ModelTypes[arg.name]) and t.name is arg
					arg = Model[arg.name]
				# nested list
				else if Array.isArray arg
					arg = _arrToModelList arg
				else unless arg and typeof arg is 'object' and _owns arg, DESCRIPTOR
					throw new Error "Illegal argument: #{arg}"
				@arrItem = arg
				return
	
		compile: (attr, schema, proto, attrPos)->
			if @arrItem
				throw new Error 'Illegal use of nested Arrays' unless @type is _ModelTypes.Array
	
				# create object schema
				objSchema = new Array 9
				objSchema[0] = 2 # -2: means list not yeat compiled
				objSchema[1] = @arrProto
				
				# items
				arrItem = @arrItem
				tp = objSchema[2] = arrItem.type
				objSchema[3] = tp.check
				objSchema[4] = tp.convert
				# nested object or array
				if arrItem.type in [_ModelTypes.Object, _ModelTypes.Array]
					objSchema[5] = new Array 9
				schema[attrPos + 5] = objSchema
			return
	
	
	# convert data to Model list
	_arrToModelList= (attrV)->
		switch attrV.length
			when 1
				Model.list attrV[0]
			when 0
				Model.list Model.Mixed
			else
				throw new Error "One type is expected for Array, #{attrV.length} are given."
	
	### compile schema ###
	_compileSchema = (schema, errors)->
		# prepare schema
		throw new Error "Illegal argument" unless schema and typeof schema is 'object'
		
		# compiled schema, @see schema.template.js for more information
		compiledSchema = new Array 6
		#  use queu instead of recursivity to prevent
		#  stack overflow and increase performance
		#  queu format: [shema, path, ...]
		seekQueue = [schema, compiledSchema, []]
		seekQueueIndex = 0
		# seek through schema
		while seekQueueIndex < seekQueue.length
			# load data from Queue
			schema			= seekQueue[seekQueueIndex]
			compiledSchema	= seekQueue[++seekQueueIndex]
			path			= seekQueue[++seekQueueIndex]
			++seekQueueIndex
			# compile
			_compileNested schema, compiledSchema, path, seekQueue, errors
		# compiled schema
		return compiledSchema	
				
	###*
	 * Compile nested object or array
	###
	# 
	_compileNested = (nestedObj, compiledSchema, path, seekQueue, errors)->
		# convert to descriptor
		nestedObj = Model.value nestedObj unless _owns nestedObj, DESCRIPTOR
		# create compiled schema
		nestedDescriptor = nestedObj[DESCRIPTOR]
		
		if nestedDescriptor.type is _ModelTypes.Object
			_compileNestedObject nestedDescriptor, compiledSchema, path, seekQueue, errors
		else if nestedDescriptor.type is _ModelTypes.Array
			_compileNestedArray nestedDescriptor, compiledSchema, path, seekQueue, errors
		else
			throw new Error "Schema could be Object or Array only!"
	###*
	 * Compile nested object
	###
	_compileNestedObject= (nestedDescriptor, compiledSchema, path, seekQueue, errors)->
		compiledSchema[0] = 1 # uncompiled object
		proto = compiledSchema[1] = _create _plainObjPrototype
		# go through object attributes
		attrPos = 9
		for attrN, attrV of nestedDescriptor.nestedObj
			try
				# check not Model
				throw new Error "Illegal use of Model" if attrV is Model
				# convert to descriptor
				attrV = Model.value attrV unless _owns attrV, DESCRIPTOR
				# get descriptor
				attrV =attrV[DESCRIPTOR]
				compiledSchema[attrPos] = attrN
				# compile: (attr, schema, proto, attrPos)
				for comp in _descriptorCompilers
					comp.call attrV, attrN, compiledSchema, proto, attrPos
				# check for illegal use of "extensible"
				throw new Error 'Illegal use of "extensible" keyword' if attrV.extensible
				# next schema
				nxtSchema = compiledSchema[attrPos + 5]
				if nxtSchema
					# nested object
					if nxtSchema[0] is 1
						throw new Error 'Nested obj required' unless attrV.nestedObj
						seekQueue.push nxtSchema, attrV.nestedObj, path.join attrN
					# nested array
					else if nxtSchema[0] is 2
						arrSchem = nxtSchema[5]
						if arrSchem
							throw new Error 'Nested obj required' unless attrV.arrItem
							seekQueue.push arrSchem, attrV.arrItem, path.join attrN, '*'
					# unknown
					else
						throw new Error "Unknown schema type: #{nxtSchema[0]}"
				# next attr position
				attrPos += 6
			catch err
				errors.push
					path: path.join attrN
					error: err
	###*
	 * Compile nested array
	###
	_compileNestedArray = (nestedDescriptor, compiledSchema, path, seekQueue, errors)->
		throw new 'Inexpected array schema' unless _owns nestedDescriptor, 'arrItem'
		compiledSchema[0] = 2 # uncompiled Array
		compiledSchema[1] = nestedDescriptor.arrProto
		# item
		arrItem = @arrItem
		tp = compiledSchema[2] = arrItem.type
		compiledSchema[3] = tp.check
		compiledSchema[4] = tp.convert
		# nested object or array
		if arrItem.type in [_ModelTypes.Object, _ModelTypes.Array]
			arrSchem = compiledSchema[5] = new Array 9
			seekQueue.push arrSchem, arrItem.arrItem || arrItem.nestedObj, path.join '*'
		return
	
	

	# Types
	###*
	* Types
	###
	
	###*
	
	 * convert Map to Object
	
	###
	
	_Map2Obj = (data)->
	
		value = _create null
	
		for k,v of data
	
			if typeof k is 'number'
	
				value[k] = v
	
			else if typeof k is 'string'
	
				throw new Error 'Could not serialize property "__proto__"' if k is '__proto__'
	
				value[k] = v
	
			else throw new Error 'Could not serialize Map'
	
		return value
	
	###*
	
	 * convert Set to Array
	
	###
	
	_Set2Array = (data) -> Array.from data
	
	
	
	###*
	
	 * Check is number
	
	###
	
	_checkIsNumber= (value) -> throw new Error "Expected positive integer" unless Number.isSafeInteger(value) and value >= 0
	
	
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
				schema[attrPos + 1] = type.check
				schema[attrPos + 2] = type.convert
			return
	###*
	 * Predefined types
	###
	Model
	###*
	 * Basic
	###
	.type
		name: 'Object'
		check: (data)-> typeof data is 'object' and not Array.isArray data
		convert: -> throw new Error 'Invalid Object'
	.type
		name: 'Array'
		check: (data)-> Array.isArray data
		convert: (data)-> [data] # accept to have the element directly when array contains just one element
		assertions:
			min:
				check: _checkIsNumber
				assert: (data, min) -> throw new Error "Array length [#{data.length}] is less then #{min}" if data.length < min
			max:
				check: _checkIsNumber
				assert: (data, max) -> throw new Error "Array length [#{data.length}] is greater then #{max}" if data.length > max
			length:
				check: _checkIsNumber
				assert: (data, len) -> throw new Error "Array length [#{data.length}] expected #{len}" if data.length isnt len
	###*
	 * Boolean
	###
	.type
		name	: Boolean
		check	: (data) -> typeof data is 'boolean'
		convert	: (data) -> !!data
	###*
	 * Number
	###
	.type
		name	: Number
		check	: (data) -> typeof data is 'number'
		convert	: (data) ->
			value = +data
			throw new Error "Invalid number #{data}" if isNaN value
			value
		# define assertion for this type
		assertions:
			min:
				check: _checkIsNumber
				assert: (data, min) -> throw new Error "value less then #{min}" if data < min
			max:
				check: _checkIsNumber
				assert: (data, max) -> throw new Error "value exceeds #{max}" if data > max
	###*
	 * Integer
	###
	.type
		name	: 'Int'
		extends	: Number
		check	: (data) -> Number.isSafeInteger data
		convert	: (data) ->
			value = +data
			throw new Error "Invalid integer #{data}" unless Number.isSafeInteger value
			value
	###*
	 * Positive integer
	###
	.type
		name	: 'Unsigned'
		extends	: Number
		check	: (data) -> Number.isSafeInteger data and data >= 0
		convert	: (data) ->
			value = +data
			throw new Error "Invalid positive integer #{data}" unless Number.isSafeInteger value and data >= 0
			value
	###*
	 * Hexadicimal number (as string)
	 * will be converted when number
	###
	.type
		name	: 'Hex'
		check	: (data) -> typeof data is 'string' and HEX_CHECK.test data
		convert	: (data) ->
			throw new Error "Invalid Hex: #{data}" unless typeof data is 'number'
			data.toString 16
		assertions:
			min:
				check: _checkIsNumber
				assert: (data, min)-> throw new Error "value less then #{min}" if Number.parse(data, 16) < min
			max:
				check: _checkIsNumber
				assert:(data, max)-> throw new Error "value greater then #{max}" if Number.parse(data, 16) > max
	
	###*
	 * Date
	###
	.type
		name	: Date
		check	: (data) -> data instanceof Date
		convert	: (data) ->
			v= new Date data
			throw new Error "Invalid date: #{data}" if v.toString() is 'Invalid Date'
			v
		assertions:
			min: # min date
				check: (value)-> throw new Error 'Expected valid date' unless value instanceof Date
				assert: (data, min)-> throw new Error "Date before #{min}" if value < min
			max: # max date
				check: (value)-> throw new Error 'Expected valid date' unless value instanceof Date
				assert: (data, max)-> throw new Error "value greater then #{max}" if Number.parse(max, 16) > max
	###*
	 * Buffer
	###
	.type
		name	: Buffer
		check	: (data) -> data instanceof Buffer
		convert	: (data) -> new Buffer data
	###*
	 * Map
	###
	.type
		name	: Map
		check	: (data) -> data instanceof Map
		convert	: (data) ->
			throw new Error "Invalid Map: #{data}" unless typeof data is 'object'
			new Map Object.entries data
		toJSON	: _Map2Obj
		toDB	: _Map2Obj
	
	###*
	 * Set
	###
	.type
		name	: Set
		check	: (data) -> data instanceof Set
		convert	: (data) ->
			throw new Error "Invalid Set: #{data}" unless Array.isArray data
			new Set data
		toJSON	: _Set2Array
		toDB	: _Set2Array
	###*
	 * WeakMap
	###
	.type
		name	: WeakMap
		check	: (data) -> data instanceof WeakMap
		convert	: (data) ->
			throw new Error "Invalid WeakMap: #{data}" unless typeof data is 'object'
			new WeakMap Object.entries data
		toJSON	: _Map2Obj
		toDB	: _Map2Obj
	###*
	 * WeakSet
	###
	.type
		name	: WeakSet
		check	: (data) -> data instanceof WeakSet
		convert	: (data) ->
			throw new Error "Invalid WeakSet: #{data}" unless Array.isArray data
			new WeakSet data
		toJSON	: _Set2Array
		toDB	: _Set2Array
	###*
	 * Text
	 * String as it is
	 * max length is STRING_MAX
	###
	.type
		name	: 'Text'
		check	: (data) -> typeof data is 'string'
		convert	: (data) -> data.toString()
		assertions:
			min:
				check: _checkIsNumber
				assert: (data, min)-> throw new Error "String length less then #{min}" if data.length < min
			max:
				check: _checkIsNumber
				assert: (data, max)-> throw new Error "String exceeds #{max}" if data.length > max
			length:
				check: _checkIsNumber
				assert: (data, len)-> throw new Error "String length [#{data.length}] expected #{len}" if data.length isnt len
			# match regex
			match:
				check: (value)-> throw new Error 'Expected RegExp' unless value instanceof RegExp
				assert: (data, regex)-> throw new Error "Expected to match: #{regex}" unless regex.test data.href
		assert	:
			max: STRING_MAX
	###*
	 * String
	 * HTML will be escaped
	###
	.type
		name	: String
		extends : 'Text'
		pipe	: (data)-> xss.escape data
	###*
	 * URL
	###
	.type
		name	: URL
		check	: (data) -> data instanceof URL
		convert	: (data) -> new URL datadata.href || data
		assertions:
			min:
				check: _checkIsNumber
				assert: (data, min)->
					urlLen = data.href.length
					throw new Error "URL length [#{urlLen}] is less then #{min}" if urlLen < min
			max:
				check: _checkIsNumber
				assert: (data, max)->
					urlLen = data.href.length
					throw new Error "URL length [#{urlLen}] is greater then #{max}" if urlLen > max
			length:
				check: _checkIsNumber
				assert: (data, len)->
					urlLen = data.href.length
					throw new Error "URL length [#{urlLen}] expected #{len}" if urlLen isnt len
			match:
				check: (value)-> throw new Error 'Expected RegExp' unless value instanceof RegExp
				assert: (data, regex)-> throw new Error "Expected to match: #{regex}" unless regex.test data.href
		assert	:
			max: URL_MAX_LENGTH
		toJSON	: (data) -> data.href
		toDB	: (data) -> data.href # save to database
	###*
	 * Image URL
	###
	.type
		name	: 'Image'
		extends	: URL
		assert	:
			max: DATA_URL_MEX_LENGTH
	###*
	 * HTML
	 * String, remove images, remove dangerous code
	###
	.type
		name	: 'HTML'
		extends	: 'Text'
		assert	:
			max: HTML_MAX_LENGTH
		pipe	: (data)-> xss.clean data, imgs: off
	###*
	 * HTML with images
	 * remove dangerouse code
	###
	.type
		name	: 'HTMLImgs'
		extends	: 'Text'
		assert	:
			max: HTML_MAX_LENGTH
		pipe	: (data)-> xss.clean data, imgs: on
	###*
	 * Email
	###
	.type
		name	: 'Email'
		extends	: 'Text'
		check	: (data) -> typeof data is 'string' and EMAIL_CHECK.test data
		convert	: (data) -> throw new Error "Invalid Email: #{data}"
		assert	:
			max: STRING_MAX
	###*
	 * Password
	###
	.type
		name	: 'Password'
		extends	: 'Text'
		convert	: (data) -> throw new Error "Invalid Password: #{data}"
		assert	:
			min: PASSWD_MIN
			max: PASSWD_MAX
	###*
	 * Mongo ObjectId
	###
	.type
		name	: 'ObjectId'
		check	: (data) -> typeof data is 'object' and data._bsontype is 'ObjectID'
		convert	: (data) -> ObjectId.createFromHexString data #TODO make this logic
	###*
	 * UUID
	###
	.type
		name	: 'UUID'
		check	: (data) -> 
		convert	: (data) ->
	###*
	 * Mixed
	###
	.type
		name	: 'Mixed'
		check	: -> true
	
	
	# property name error notifier
	_setPrototypeOf _schemaDescriptor, new Proxy {},
		get: (obj, attr) -> throw new Error "Unknown Model property: #{attr}"
		set: (obj, attr, value) -> throw new Error "Unknown Model property: #{attr}"

	# interface
	
	module.exports = Model
	