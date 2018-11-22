
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
	compile: (attr, schema, proto)->
		#TODO
		schema[SCHEMA.extensible] = @extensible isnt off
		return

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
				throw new Errro "Getter expects no argument" unless fx.length is 0
				@getter = fx
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
		if _owns this, assertObj
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
			throw new Error "Expected sub schema" unless typeof arg is 'object' and arg and not arg[DESCRIPTOR]
			throw new Error "Use '[]' instead of '.value' to create lists" if Array.isArray arg
			@subschema = arg
			return
		compile: (attr, schema, proto, attrPos)->
			# will be compiled, just to avoid recursivity
			schema[attrPos + <%= SCHEMA.attrSchema %>] =  @subschema if @subschema
			return

###*
 * List
 * @example
 * .list(Number)
 * .list({sub-schema})
 * .list(Model.Int)
 * .list(Model.list(...))
###
_defineDescriptor
	fx:
		list: (arg)->
			<%= assertArgsLength(1) %>
			@list = true