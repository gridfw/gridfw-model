###*
 * Check/Convert data
###
_defineDescriptors
	check: (descriptor, fx)->
		throw "Expected function" unless typeof fx is 'function'
		descriptor[<%= SCHEMA_DESC.check %>] = fx
		return
	convert: (descriptor, fx)->
		throw "Expected function" unless typeof fx is 'function'
		descriptor[<%= SCHEMA_DESC.convert %>] = fx
		return
# check
_defineCompiler <%= SCHEMA_DESC.check %>, (descriptorV, attr, schema, proto, attrPos)->
	schema[attrPos + <%= SCHEMA.attrCheck %>] = descriptorV
	# list, TODO
	if @arrItem
		objSchema= schema[attrPos + <%= SCHEMA.attrSchema %>]
		objSchema[<%= SCHEMA.listCheck %>] = arrItem[<%= SCHEMA_DESC.check %>]
	return
# convert
_defineCompiler <%= SCHEMA_DESC.convert %>, (descriptorV, attr, schema, proto, attrPos)->
	schema[attrPos + <%= SCHEMA.attrConvert %>] = descriptorV
	# list, TODO
	if @arrItem
		objSchema= schema[attrPos + <%= SCHEMA.attrSchema %>]
		objSchema[<%= SCHEMA.listConvert %>] = arrItem[<%= SCHEMA_DESC.convert %>]
	return

###*
 * JSON ignore
###
_defineDescriptors
	jsonIgnore: (descriptor)-> descriptor[<%= SCHEMA_DESC.jsonIgnore %>] = 3 # ignore json, 3 = 11b = ignoreSerialize | ignoreParse
	jsonIgnoreStringify: (descriptor)-> descriptor[<%= SCHEMA_DESC.jsonIgnore %>] = 1 # ignore when serializing: 1= 1b
	jsonIgnoreParse: (descriptor)-> descriptor[<%= SCHEMA_DESC.jsonIgnore %>] = 2 # ignore when parsing: 2 = 10b
	jsonEnable: (descriptor)-> descriptor[<%= SCHEMA_DESC.jsonIgnore %>] = 0 # include this attribute with JSON, @default

	toJSON: (descriptor, fx)->
		throw new Error "Expected function" unless typeof fx is 'function'
		descriptor[<%= SCHEMA_DESC.toJSON %>] = fx
		return
# check descriptor
_descriptorCheck (descriptor)->
	# when required
	if descriptor[<%= SCHEMA_DESC.required %>]
		jsonIgnore= descriptor[<%= SCHEMA_DESC.jsonIgnore %>]
		if (typeof jsonIgnore is 'number') and jsonIgnore & 2
			throw new Error 'Attribute set as required and to be ignored when parsing JSON!'
	return
# JSON ignore
_defineCompiler <%= SCHEMA_DESC.jsonIgnore %>, (jsonIgnore, attr, schema, proto, attrPos)->
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
		ignoreParse.push attr
	return
# ToJSON
_defineCompiler <%= SCHEMA_DESC.toJSON %>, (toJSON, attr, schema, proto, attrPos)->
	(schema[<%= SCHEMA.toJSON %>] ?= []).push attr, @toJSON
	return

###*
 * Virtual methods
###
_defineDescriptors
	virtual: (descriptor)-> descriptor[<%= SCHEMA_DESC.virtual %>] = on
	transient: (descriptor)-> descriptor[<%= SCHEMA_DESC.virtual %>] = on
	persist: (descriptor)-> descriptor[<%= SCHEMA_DESC.virtual %>] = off
	# change DB representation
	toDB: (descriptor, fx)->
		throw new Error "Expected function" unless typeof fx is 'function'
		descriptor[<%= SCHEMA_DESC.toDB %>] = fx
		return
# Virtual
_defineCompiler <%= SCHEMA_DESC.virtual %>, (isVirtual, attr, schema, proto, attrPos)->
	virtualAttrs = schema[<%= SCHEMA.virtual %>] ?= []
	# remove attr from virtual list
	_arrRemoveItem virtualAttrs, attr
	# add if virtual
	virtualAttrs.push attr if isVirtual
	return
# ToDB
_defineCompiler <%= SCHEMA_DESC.toDB %>, (toDBFx, attr, schema, proto, attrPos)->
	(schema[<%= SCHEMA.toDB %>] ?= []).push attr, toDBFx
	return


###*
 * Set attribute as required
###
_defineDescriptors
	required: (descriptor)-> descriptor[<%= SCHEMA_DESC.required %>] = on
	optional: (descriptor)-> descriptor[<%= SCHEMA_DESC.required %>] = off
_defineCompiler <%= SCHEMA_DESC.required %>, (isRequired, attr, schema, proto, attrPos)->
	requiredAttrs = schema[<%= SCHEMA.required %>] ?= []
	# remove attr
	_arrRemoveItem requiredAttrs, attr
	# add if required
	requiredAttrs.push attr if isRequired
	return
###*
 * Set an object as freezed or extensible
 * @default freezed
###
_defineDescriptors
	freeze: (descriptor)-> descriptor[<%= SCHEMA_DESC.extensible %>] = off
	extensible: (descriptor)-> descriptor[<%= SCHEMA_DESC.extensible %>] = on
_descriptorCheck (descriptor)->
	if typeof descriptor[<%= SCHEMA_DESC.extensible %>] is 'boolean'
		unless typeof descriptor[<%= SCHEMA_DESC.nestedObject %>] is 'undefined'
			throw 'Extensible/freeze are to be used with nested object only'
	return

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
_defineDescriptors
	# default value
	default: (descriptor, value)->
		descr= descriptor[<%= SCHEMA_DESC.define %>] ?= _create null
		if typeof value is 'function'
			descr.get= value
		else
			descr.value= value
			descr.writable= on
			descr.configurable= on
			descr.enumerable= on
		return
	# getter
	getter: (descriptor, fx)->
		throw new Error "function expected" unless typeof fx is 'function'
		throw new Error "Getter expects no argument" unless fx.length is 0
		descr= descriptor[<%= SCHEMA_DESC.define %>] ?= _create null
		descr.get= fx
		return
	# generate value once and set it to this object
	getterOnce: (descriptor, fx)->
		throw new Error "function expected" unless typeof fx is 'function'
		throw new Error "Getter expects no argument" unless fx.length is 0
		descr= descriptor[<%= SCHEMA_DESC.define %>] ?= _create null
		descr.get= ->
			vl = fx.call this
			_defineProperty this, attr,
				value: vl
				configurable: on
				enumerable: on
				writable: on
			return vl
		return
	# setter
	setter: (descriptor, fx)->
		throw new Error "function expected" unless typeof fx is 'function'
		throw new Error "Setter expects signature: function(value){}" unless fx.length is 1
		descr= descriptor[<%= SCHEMA_DESC.define %>] ?= _create null
		descr.set= fx
		return
	###*
	 * Alias
	 * @example
	 * .alias('attrName')	# alias to this attribute
	 * .alias(-> getter_expr)# alias to .getter(-> getter_expr)
	###
	alias: (descriptor, value)->
		throw new Error "Alias expects property name as argument" unless typeof value is 'string'
		descr= descriptor[<%= SCHEMA_DESC.define %>] ?= _create null
		descr.get= -> @[value]
		descr.set= (data)->
			@[value] = data
			return
		return
# check descriptor when validation
_descriptorCheck (descriptor)->
	defineDesc = descriptor[<%= SCHEMA_DESC.define %>]
	# use of "default"
	if ('value' of defineDesc) and ('get' of defineDesc or 'set' of defineDesc)
		throw 'Could not use a getter/setter when a default value or prototype property is set.'
	return
# compile
_defineCompiler <%= SCHEMA_DESC.define %>, (descrp, attr, schema, proto, attrPos)->
	_defineProperty proto, attr, descrp
	return

###*
 * Assertions
 * Used when validating data
 * @example
 * .assert(true)
 * .assert(call(this, data, attrName)-> data.isTrue())
 * .assert((data)-> throw new Error "Error message: #{data}")
 *
 * # add assertions
 * .assertions({
 * 		min: (data, param)-> throw "data less then #{param}" if data < param
 * 		max:
 * 			param: (param)-> throw 'Expected number' unless typeof param is 'number'
 * 			assert: (value, param)-> throw "data less then #{param}" if data < param
 * 	})
###
_defineDescriptors
	# assert
	assert: (descriptor, assertion)->
		# assertion object
		if typeof assertion is 'object' and assertion
			Object.assign (descriptor[<% SCHEMA_DESC.assertPredefined %>] ?= _create null), assertion
		else
			# convert to function
			if typeof assertion isnt 'function'
				vl = assertion
				assertion = (data)-> throw new Error "Doesn't equal: #{vl}" unless data is vl
			# add to assertions
			(descriptor[<% SCHEMA_DESC.asserts %>] ?= []).push assertion
		return
	# assertions
	assertions: (descriptor, options)->
		throw new Error 'Expected Object' unless typeof options is 'object' and options
		assertions= [<% SCHEMA_DESC.assertions %>] ?= _create null
		for k,v of options
			if typeof v is 'function'
				v= assert: v
			else typeof v is 'object' and v
				throw new Error "#{k}.assert expected function" unless typeof v.assert is 'function'
				throw new Error "#{k}.param expected function" if 'param' of v and typeof v.param isnt 'function'
			else
				throw new Error "Illegal option: #{k}"
			assertions[k]= v
		return
# asserts
_defineCompiler <% SCHEMA_DESC.asserts %>, (asserts, attr, schema, proto, attrPos)->
	assertArr = schema[attrPos + <%= SCHEMA.attrAsserts %>] ?= []
	assertArr.push el for el in asserts
	return
# predefined asserts
_defineCompiler <% SCHEMA_DESC.assertPredefined %>, (asserts, attr, schema, proto, attrPos, descriptor)->
	assertions= descriptor[<% SCHEMA_DESC.assertions %>]
	throw new Error 'Assertions missed: did you forget to set the type?' unless assertions
	# go through assertions
	schemaPropertyAsserts = schema[attrPos + <%= SCHEMA.attrPropertyAsserts %>] ?= []
	# iterations
	for k,v of asserts
		ast = assertions[k]
		throw new Error "Missing assertion: #{k}" unless ast
		# check param
		ast.param v if ast.param
		# save
		schemaPropertyAsserts.push k, v, ast.assert
	return

###*
 * Pipeline
###
_defineDescriptors
	pipe: (descriptor, fx)->
		throw "Expected function" unless typeof fx is 'function'
		(descriptor[<% SCHEMA_DESC.pipe %>] ?= []).push fx
		return
_defineCompiler <% SCHEMA_DESC.pipe %, (pipeLine, attr, schema, proto, attrPos)->
	pipeArr = schema[attrPos + <%= SCHEMA.attrPipe %>] ?= []
	pipeArr.push el for el in pipeLine
	return

###*
 * Reference
###
_defineDescriptors
	ref: (descriptor, ref)->
		throw 'Expected string as reference' unless typeof ref is 'string'
		throw 'Empty reference' unless ref
		descriptor[<% SCHEMA_DESC.ref %>] = ref
		return
_descriptorCheck (descriptor)->
	if descriptor[<% SCHEMA_DESC.ref %>]
		# nested object or list
		#TODO
		throw new Error 'Could not use reference, nested object and nested list at the same time'

_defineCompiler <% SCHEMA_DESC.ref %>, (ref, attr, schema, proto, attrPos)->
	schema[attrPos + <%= SCHEMA.attrRef %>]= ref
	return

###*
 * Value
 * @example
 * .value(Number) equivalent to: Number
 * .value(sub-schema) equivalent to: sub-schema
 * .value(Model.Int) equivalent to: Model.Int
 * .value(function(){}) equivalent to: function(){}
###
_defineDescriptors
	value: (descriptor, arg)->
		# is function
		if typeof arg is 'function'
			# check if registred directive
			if Model.hasDirective arg #TODO change this
				arg= Model[arg.name]
			# if date.now, set it as default value
			else if arg is Date.now
				arg= Model.default arg
			# else add this function as prototype property
			else
				descriptor[<% SCHEMA_DESC.define %>]= value: arg
				return
		# if it is an array of objects
		else if Array.isArray arg
			switch arg.length
				when 1
					arg= Model.list arg[0]
				when 0
					arg= Model.list Model.Mixed
				else
					throw new Error "One type is expected for Array, #{attrV.length} are given."
		# nested object
		else if typeof arg is 'object'
			unless _owns arg, DESCRIPTOR
				arg= Model.Object
				descriptor[<% SCHEMA_DESC.nestedObject %>]= arg
		# error
		else
			throw new Error "Illegal attribute descriptor"

		# override attributes
		for v,i in arg[DESCRIPTOR]
			unless typeof v is 'undefined'
				descriptor[i]=v
		return
_defineCompiler <% SCHEMA_DESC.nestedObject %>, (nestedObj, attr, schema, proto, attrPos, descriptor)->
	# check for a schema
	objSchema = schema[attrPos + <%= SCHEMA.attrSchema %>]
	if objSchema
		throw new Error "Illegal convertion to object" if objSchema[<%= SCHEMA.schemaType %>] isnt <%= SCHEMA.OBJECT %>
		# extensibility
		if typeof descriptor[<% SCHEMA_DESC.extensible %>] is 'boolean'
			objSchema[<%= SCHEMA.extensible %>]= descriptor[<% SCHEMA_DESC.extensible %>]
	else
		objSchema = schema[attrPos + <%= SCHEMA.attrSchema %>] = [] # new Array <%= SCHEMA.sub %>
		objSchema[<%= SCHEMA.schemaType %>] = <%= SCHEMA.OBJECT %>
		# extensibility
		if typeof descriptor[<% SCHEMA_DESC.extensible %>] is 'boolean'
			objSchema[<%= SCHEMA.extensible %>]= descriptor[<% SCHEMA_DESC.extensible %>]
		else
			objSchema[<%= SCHEMA.extensible %>]= schema[<%= SCHEMA.extensible %>] # inheritance
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
_defineDescriptors
	list: (descriptor, arg, prototype)->
		


------------------------------------------------------ TODO --------------------------------------------------------------------
Model.ignoreProps 'attr1', 'attr2' # ignore properties
Model.filterProps 'attr1', 'attr2' # accept those properties only




.fromDB
.toDB

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
				_defineProperties objSchema[<%= SCHEMA.proto %>], Object.getOwnPropertyDescriptors @arrProto
				@arrProto = objSchema[<%= SCHEMA.proto %>]
			else
				console.log "#{attr}>> new "
				objSchema = schema[attrPos + <%= SCHEMA.attrSchema %>] = [] # new Array <%= SCHEMA.sub %>
				objSchema[<%= SCHEMA.schemaType %>] = 2 # -2: means list not yeat compiled
				objSchema[<%= SCHEMA.proto %>] = @arrProto
				throw new Error "Array type not set!" if @arrItem is null
			
			# items#TODO remove
			if @arrItem
				arrItem = @arrItem[DESCRIPTOR]
				# tp = objSchema[<%= SCHEMA.listType %>] = arrItem.type
				# objSchema[<%= SCHEMA.listCheck %>] = tp.check
				# objSchema[<%= SCHEMA.listConvert %>] = tp.convert
				# nested object or array
				arrSchem = null
				if arrItem.type in [_ModelTypes.Object, _ModelTypes.Array]
					if 'ref' of arrItem
						objSchema[<%= SCHEMA.listRef %>]= arrItem.ref
					else
						arrSchem ?= [] #new Array <%= SCHEMA.sub %>
					
				objSchema[<%= SCHEMA.listSchema %>]= arrSchem
		return




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
