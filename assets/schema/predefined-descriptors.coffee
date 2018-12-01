
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
			ignoreJSONAttr = schema[<%= SCHEMA.ignoreJSON %>]
			if ignoreJSONAttr
				ignoreJSONAttr.push attr
			else
				ignoreJSONAttr = schema[<%= SCHEMA.ignoreJSON %>] = [attr]
				_defineProperties proto, toJSON: -> _toJSONCleaner this, ignoreJSONAttr
		# ignore when parsing
		if jsonIgnore & 2
			#TODO add this to "model.fromJSON"
			(schema[<%= SCHEMA.ignoreParse %>] ?= []).push attr
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
			virtualAttr = schema[<%= SCHEMA.virtual %>]
			if virtualAttr
				virtualAttr.push attr
			else
				virtualAttr = schema[<%= SCHEMA.virtual %>] = [attr]
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
				<%= assertArgsLength(1,2) %>
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
			<%= assertArgsLength(1) %>
			(@assertObj ?= _create null).length = value
		min: (min)->
			<%= assertArgsLength(1) %>
			(@assertObj ?= _create null).min = min
		max: (max)->
			<%= assertArgsLength(1) %>
			(@assertObj ?= _create null).max = max
		between: (min, max)->
			<%= assertArgsLength(2) %>
			assertObj = @assertObj ?= _create null
			assertObj.min = min
			assertObj.max = max
			return
		match: (regex)->
			<%= assertArgsLength(1) %>
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
			schema[attrPos + <%= SCHEMA.attrAsserts %>] = @asserts
		return

### pipe ###
_defineDescriptor
	fx:
		pipe: (fx)->
			<%= assertArgsLength(1) %>
			throw new Error "Expected function" unless typeof fx is 'function'
			(@pipe ?= []).push fx
			return
	compile: (attr, schema, proto, attrPos)->
		if _owns this, 'pipe'
			schema[attrPos + <%= SCHEMA.attrPipe %>] = @pipe

###*
 * toJSON / toDB
###
_defineDescriptor
	fx:
		toJSON: (fx)->
			<%= assertArgsLength(1) %>
			throw new Error "Expected function" unless typeof fx is 'function'
			@toJSON = fx
			return
		toDB: (fx)->
			<%= assertArgsLength(1) %>
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
			<%= assertArgsLength(1) %>
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
				
				objSchema = new Array <%= SCHEMA.sub %>
				# objSchema[<%= SCHEMA.schemaType %>] = 1 # -1: means object not yeat compiled
				# objSchema[<%= SCHEMA.proto %>] = _create _plainObjPrototype
				objSchema[<%= SCHEMA.extensible %>] = @extensible || off
				delete @extensible

				schema[attrPos + <%= SCHEMA.attrSchema %>] = objSchema
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
			console.log '----', arg
			<%= assertArgsLength(1, 2) %>
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
			# # arg
			# # predefined type
			# if typeof arg is 'function'
			# 	throw new Error 'Illegal argument' unless (t = _ModelTypes[arg.name]) and t.name is arg
			# 	arg = Model[arg.name]
			# # nested list
			# else if Array.isArray arg
			# 	arg = _arrToModelList arg
			# else if typeof arg is 'object' and 
			# else unless arg and typeof arg is 'object' and _owns arg, DESCRIPTOR
			# 	throw new Error "Illegal argument: #{arg}"
			@arrItem = Model.value arg
			return

	compile: (attr, schema, proto, attrPos)->
		if @arrItem
			throw new Error 'Illegal use of nested Arrays' unless @type is _ModelTypes.Array

			# create object schema
			objSchema = new Array <%= SCHEMA.sub %>
			objSchema[<%= SCHEMA.schemaType %>] = 2 # -2: means list not yeat compiled
			objSchema[<%= SCHEMA.proto %>] = @arrProto
			
			# items
			arrItem = @arrItem
			tp = objSchema[<%= SCHEMA.listType %>] = arrItem.type
			objSchema[<%= SCHEMA.listCheck %>] = tp.check
			objSchema[<%= SCHEMA.listConvert %>] = tp.convert
			# nested object or array
			if arrItem.type in [_ModelTypes.Object, _ModelTypes.Array]
				objSchema[<%= SCHEMA.listSchema %>] = new Array <%= SCHEMA.sub %>
			schema[attrPos + <%= SCHEMA.attrSchema %>] = objSchema
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