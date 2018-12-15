
###*
 * JSON cleaner
 * @param  {Array<String>} whiteList  - attributes to include or null
 * @param  {Array<String>} ignoreAttr - attributes to exclude or null
 * @param  {Array<attrName, toJSONFx, ...>} toJSONList     - Attributes with special JSON traitement
 * @return {function}            - toJSON method
###
_toJSONCleaner = (whiteList, ignoreAttr, toJSONList)->
	# process white list
	if whiteList and ignoreAttr
		whiteList = _arrDiff whiteList, ignoreAttr
	# toJSON/toDB function
	->
		clone = _create null
		# white list
		if whiteList
			for k,v of this
				if (_owns this, k) and k in whiteList
					clone[k] = v
		# ignored list
		else if ignoreAttr
			for k,v of this
				if (_owns this, k) and k not in ignoreAttr
					clone[k] = v
		# just clone
		else
			Object.assign clone, this
		# attr with special fx
		if toJSONList and toJSONList.length
			len = toJSONList.length
			i = 0
			while i < len
				# load attr and fx
				attr = toJSONList[i]
				fx = toJSONList[++i]
				++i
				# apply
				if attr of clone
					clone[attr] = fx.call this, clone[attr], attr
		# return
		clone
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
		# change attribute JSON representation
		toJSON: (fx)->
			<%= assertArgsLength(1) %>
			throw new Error "Expected function" unless typeof fx is 'function'
			@toJSON = fx
			return
	# Compile Prototype and schema
	compile: (attr, schema, proto, attrPos)->
		if _owns this, 'jsonIgnore'
			jsonIgnore = @jsonIgnore
			ignoreParse = schema[<%= SCHEMA.ignoreParse %>] ?= []
			ignoreSerialize = schema[<%= SCHEMA.ignoreJSON %>] ?= []
			# remove this attr from JSON flags
			_arrRemoveItem ignoreParse, attr
			_arrRemoveItem ignoreSerialize, attr
			# do not serialize attribute
			if jsonIgnore & 1
				ignoreSerialize.push attr
			# ignore when parsing
			if jsonIgnore & 2
				#TODO add this to "model.fromJSON"
				ignoreParse.push attr
		# JSON representation of an element
		(schema[<%= SCHEMA.toJSON %>] ?= []).push attr, @toJSON if @toJSON
		return
	# final adjust
	finally: (schema, proto) ->
		ignoreSerialize = schema[<%= SCHEMA.ignoreJSON %>]
		toJSONList = schema[<%= SCHEMA.toJSON %>]
		isExtensible = schema[<%= SCHEMA.extensible %>]
		# using white list
		if isExtensible is off
			toJSONFx = _toJSONCleaner (_getSchemaAttributes schema), ignoreSerialize, toJSONList
		else if (ignoreSerialize and ignoreSerialize.length) or (toJSONList and toJSONList.length)
			toJSONFx = _toJSONCleaner null, ignoreSerialize, toJSONList
		else
			toJSONFx = null
		# apply
		_defineProperty proto, 'toJSON',
			configurable: on
			value: toJSONFx
		return
###*
 * Virtual methods
###
_defineDescriptor
	get:
		virtual: -> @virtual = on
		transient: -> @virtual = on
		persist: -> @virtual = off
		# change DB representation
		toDB: (fx)->
			<%= assertArgsLength(1) %>
			throw new Error "Expected function" unless typeof fx is 'function'
			@toDB = fx
			return
	compile: (attr, schema, proto)->
		if _owns this, 'virtual'
			virtualAttrs = schema[<%= SCHEMA.virtual %>] ?= []
			# remove attr from virtual list
			_arrRemoveItem virtualAttrs, attr
			# add if virtual
			virtualAttrs.push attr if @virtual
		# to DB
		(schema[<%= SCHEMA.toDB %>] ?= []).push attr, @toDB if @toDB
		return
	# final adjust
	finally: (schema, proto) ->
		virtualAttrs = schema[<%= SCHEMA.virtual %>]
		toDBList = schema[<%= SCHEMA.toDB %>]
		isExtensible = schema[<%= SCHEMA.extensible %>]
		# using white list
		if isExtensible is off
			toDBFx = _toJSONCleaner (_getSchemaAttributes schema), virtualAttrs, toDBList
		else if (virtualAttrs and virtualAttrs.length) or (toDBList and toDBList.length)
			toDBFx = _toJSONCleaner null, virtualAttrs, toDBList
		else
			toDBFx = null
		# apply
		_defineProperty proto, 'toJSON',
			configurable: on
			value: toDBFx
		return
###*
 * Set attribute as required
###
_defineDescriptor
	get:
		required: -> @required = on
		optional: -> @required = off
	compile: (attr, schema, proto)->
		if _owns this, 'required'
			requiredAttrs = schema[<%= SCHEMA.required %>] ?= []
			# remove attr
			_arrRemoveItem requiredAttrs, attr
			# add if required
			requiredAttrs.push attr if @required
		return

###*
 * Set an object as freezed or extensible
 * @default freezed
###
_defineDescriptor
	get:
		freeze: -> @extensible = off
		extensible: -> @extensible = on
###*
 * Default value
 * getters / setters
 * .default(8).default('static value').default(true) # default static value
 * .default(window) # static value
 * .default({}) # be careful !! some object will set for all instances
 * .default(=>{}) # create new object for each instance.
 * .default(-> this.attr ) # generating default value from function
 * .default(Date.now) # generating default value from function
 *
 * .getter(-> value) # add getter
 * .setter(-> value) # add setter
 *
 * .getterOnce(4)	# when no value set, set this static value
 * .getterOnce(fx)	# use this fx to generate value when not set (called once or after deleting value)
 *
 * .alias('attrName') # alias to this attribute
 * .alias(fx)		# getter
###
_defineDescriptor
	fx:
		# default value
		default: (value)->
			<%= assertArgsLength(1) %>
			@default = value
			return
		# getter
		getter: (fx)->
			<%= assertArgsLength(1) %>
			throw new Error "function expected" unless typeof fx is 'function'
			throw new Error "Getter expects no argument" unless fx.length is 0
			@getter = fx
			return
		# generate value once and set it to this object
		getterOnce: (value)->
			<%= assertArgsLength(1) %>
			@getterOnce = value
			return
		# setter
		setter: (fx)->
			throw new Error "Illegal arguments" unless arguments.length is 1
			throw new Error "function expected" unless typeof fx is 'function'
			throw new Error "Setter expects signature: function(value){}" unless fx.length is 1
			@setter = fx
			return
		###*
		 * Alias
		 * @example
		 * .alias('attrName')	# alias to this attribute
		 * .alias(-> getter_expr)# alias to .getter(-> getter_expr)
		###
		alias: (value)->
			<%= assertArgsLength(1) %>
			# alias to attribute
			if typeof value is 'string'
				@getter = -> @[value]
			# getter
			else if typeof value is 'function'
				@_.getter value
			else
				throw new Error "Illegal argument for [alias] method"
			return
	compile: (attr, schema, proto)->
		# getter or setter
		if typeof @getter is 'function' or typeof @setter is 'function'
			_defineProperty proto, attr,
				configurable: on
				get: @getter
				set: @setter
		# getter once
		else if _owns this, 'getterOnce'
			getterOnce = @getterOnce
			_defineProperty proto, attr,
				configurable: on
				get: ->
					vl = if typeof getterOnce is 'function' then (getterOnce.call this) else getterOnce
					_defineProperty this, attr,
						value: vl
						configurable: on
						enumerable: on
						writable: on
					vl
		# default value as function
		else if typeof @default is 'function'
			_defineProperty proto, attr,
				configurable: on
				get: @default
		# default value
		else if _owns this, 'default'
			_defineProperty proto, attr,
				configurable: on
				value: @default
		return

###*
 * Assertions
 * Used when validating data
 * @example
 * .assert(true)
 * .assert(true, 'Optional Error message')
 * .assert(call(this, data, attrName)-> data.isTrue())
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
			type = @type || schema[attrPos + <%= SCHEMA.attrType %>]
			throw new Error "No type specified to use predefined assertions. Use assert(function(data){}) instead" unless type
			typeAssertions = type.assertions
			throw new Error "No assertions predefined for type [#{type.name}]. Use assert(function(data){}) instead" unless typeAssertions
			# go through assertions
			schemaPropertyAsserts = schema[attrPos + <%= SCHEMA.attrPropertyAsserts %>] ?= _create null
			# iterations
			for k,v of @assertObj
				throw new Error "No predefined assertion [#{k}] on type [#{type.name}]" unless _owns typeAssertions, k
				# check value
				assertC = typeAssertions[k]
				assertC.check v
				# add assertion
				# schemaPropertyAsserts[k] = _assertGen assertC.assert, v
				schemaPropertyAsserts[k] = v
		# add asserts
		if _owns this, 'asserts'
			assertArr = schema[attrPos + <%= SCHEMA.attrAsserts %>] ?= []
			assertArr.push el for el in @asserts
		return

# # generate assertion
# _assertGen = (assert, value)->
# 	(obj, data, attr) -> assert.call obj, data, value, attr
### pipe call(this, data, attrName) ###
_defineDescriptor
	fx:
		pipe: (fx)->
			<%= assertArgsLength(1) %>
			throw new Error "Expected function" unless typeof fx is 'function'
			(@pipe ?= []).push fx
			return
	compile: (attr, schema, proto, attrPos)->
		if @pipe
			pipeArr = schema[attrPos + <%= SCHEMA.attrPipe %>] ?= []
			pipeArr.push el for el in @pipe
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

		# Object
		if @nestedObj
			# check for a schema
			objSchema = schema[attrPos + <%= SCHEMA.attrSchema %>]
			if objSchema
				throw new Error "Illegal convertion to object" if objSchema[<%= SCHEMA.schemaType %>] isnt 1
				# extensibility
				objSchema[<%= SCHEMA.extensible %>] = @extensible if _owns(this, 'extensible')
			else
				objSchema = schema[attrPos + <%= SCHEMA.attrSchema %>] = [] # new Array <%= SCHEMA.sub %>
				objSchema[<%= SCHEMA.schemaType %>] = 1 # 1: means object
				# extensibility
				objSchema[<%= SCHEMA.extensible %>] = if _owns(this, 'extensible') then @extensible else schema[<%= SCHEMA.extensible %>] # inherit
			
			# objSchema[<%= SCHEMA.extensible %>] = @extensible || off
		# extensible is alowed only on objects
		else if _owns this, 'extensible'
			throw new Error '"extensible/freeze" keywords are to be used with objects only'
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
			if arg in [null, undefined]
				@arrItem = null
			else
				@arrItem = Model.value arg
			return

	compile: (attr, schema, proto, attrPos)->
		if _owns this, 'arrItem'
			throw new Error 'Illegal use of nested Arrays' unless @type is _ModelTypes.Array

			# create object schema
			objSchema= schema[attrPos + <%= SCHEMA.attrSchema %>]
			if objSchema
				console.log "#{attr}>> already"
				throw new Error "Illegal convertion to Array" if objSchema[<%= SCHEMA.schemaType %>] isnt 2
				# proto
				@arrProto = _defineProperties objSchema[<%= SCHEMA.proto %>], Object.getOwnPropertyDescriptors @arrProto
			else
				console.log "#{attr}>> new "
				objSchema = schema[attrPos + <%= SCHEMA.attrSchema %>] = [] # new Array <%= SCHEMA.sub %>
				objSchema[<%= SCHEMA.schemaType %>] = 2 # -2: means list not yeat compiled
				objSchema[<%= SCHEMA.proto %>] = @arrProto
				throw new Error "Array type not set!" if @arrItem is null
			
			# items#TODO remove
			if @arrItem
				arrItem = @arrItem[DESCRIPTOR]
				tp = objSchema[<%= SCHEMA.listType %>] = arrItem.type
				objSchema[<%= SCHEMA.listCheck %>] = tp.check
				objSchema[<%= SCHEMA.listConvert %>] = tp.convert
				# nested object or array
				if arrItem.type in [_ModelTypes.Object, _ModelTypes.Array]
					arrSchem = objSchema[<%= SCHEMA.listSchema %>] ?= [] #new Array <%= SCHEMA.sub %>
				else
					arrSchem = null
				objSchema[<%= SCHEMA.listSchema %>]= arrSchem
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