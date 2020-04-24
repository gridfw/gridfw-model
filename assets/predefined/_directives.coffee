###*
 * Predefined directives
###
ModelClass

# TYPE
# check @deprecated
.addDirective 'check', 'function', (fx)-> @check= fx
# Convert
.addDirective 'convert', 'function', (fx)-> @convert= fx
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	# prepare descriptor
	#TODO Prepare type
	_setPrototypeOf this, @type
	# Add to schema
	schema[<%=SCHEMA_ATTR.name %>+attrIndex]= attr
	schema[<%=SCHEMA_ATTR.type %>+attrIndex]= @type if @type
	schema[<%=SCHEMA_ATTR.convert %>+attrIndex]= @convert if @convert
	return

# Freeze
.addDirective 'freeze', -> @freeze= yes
.addDirective 'extensible', -> @freeze= no
.compileAttrDirective (schema, attr, attrIndex, prototype, parentNodeDesc)->
	isFreezed= @freeze
	flags= schema[<%=SCHEMA_ATTR.flags %>+attrIndex] or 0
	# Inherit
	if (not isFreezed?) and not (flags&<%- SCHEMA.IS_FREEZE_SET %>)
		isFreezed= @freeze= parentNodeDesc.freeze
	# Apply
	if isFreezed is true
		flags|= <%- SCHEMA.FREEZE %>
		flags|= <%- SCHEMA.IS_FREEZE_SET %>
	else if isFreezed is false
		flags&= <%- ~SCHEMA.FREEZE %>
		flags|= <%- SCHEMA.IS_FREEZE_SET %>
	# Save
	schema[<%=SCHEMA_ATTR.flags %>+attrIndex]= flags
	return

# NULL
.addDirective 'required', -> @null= no
.addDirective 'optional', -> @null= yes
.addDirective 'null', -> @null= yes
.addDirective 'notNull', -> @null= no
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	isNull= @null
	if isNull is yes
		schema[<%=SCHEMA_ATTR.flags %>+attrIndex]&= <%- ~SCHEMA.NOT_NULL %>
	else if isNull is no
		schema[<%=SCHEMA_ATTR.flags %>+attrIndex]|= <%- SCHEMA.NOT_NULL %>
	return

# JSON
.addDirective 'enableJSON',				-> @json= 0b00
.addDirective 'ignoreJsonStringify',	-> @json= 0b01
.addDirective 'ignoreJsonParse',		-> @json= 0b10
.addDirective 'ignoreJSON',				-> @json= 0b11
.addDirective 'toJSON', 'function',		(fx)-> @toJSON= fx
.addDirective 'fromJSON', 'function',	(fx)-> @fromJSON= fx

# DATABASE
.addDirective ['virtual', 'transient'], -> @virtual= yes
.addDirective 'persist', -> @virtual= no
.addDirective 'toDB', 'function', (fx)-> @toDB= fx
.addDirective 'fromDB', 'function', (fx)-> @fromDB= fx

# COMPILE DATABASE AND JSON
.compileAttrDirective do ->
	# CB When serializing (toJSON or toDataBase)
	_toWrapper= (obj, ignoreAttr, toCbs)->
		ignoreAttr= null unless ignoreAttr?.length
		toCbs= null unless toCbs?.length
		if ignoreAttr or toCbs
			# copy object
			result= {}
			if ignoreAttr
				for k of obj
					if (k not in ignoreAttr) and obj.hasOwnProperty k
						result[k]= obj[k]
			else
				_assign result, obj
			# Convert values
			if toCbs
				i=0
				len= toCbs.length
				while i<len
					attr= toCbs[i++]
					cb= toCbs[i++]
					if result.hasOwnProperty attr
						result[attr]= cb.call obj, result[attr], attr
		else
			result= obj
		return result
	# Compile JSON
	_compileJSON= (schema, attr, attrIndex, prototype)->
		# checkes
		if (json= @json)?
			schema[<%-SCHEMA_ATTR.flags %>+attrIndex]= schema[<%-SCHEMA_ATTR.flags %>+attrIndex]&(~3)|json
			# ignore when serializing
			if json&1
				(schema[<%= SCHEMA.ignoreJsonAttrs %>] ?= []).push attr
				needsProto= yes
			else if arr= schema[<%= SCHEMA.ignoreJsonAttrs %>]
				_arrRemove arr, attr
		# ToJSON
		if toJsonCb= @toJSON
			if arr= schema[<%= SCHEMA.toJSON %>]
				_arrRemove arr, attr, 2
			else
				arr= schema[<%= SCHEMA.toJSON %>]= []
			arr.push attr, toJsonCb
			needsProto= yes
		# ToJSON cb
		if needsProto
			_toJSONWrapper= -> _toWrapper(this, schema[<%= SCHEMA.ignoreJsonAttrs %>], schema[<%= SCHEMA.toJSON %>])
			for wrp in ModelClass.TO_JSON
				_defineProperty prototype, wrp,
					value: _toJSONWrapper
					configurable: yes
		# fromJSON
		schema[<%= SCHEMA_ATTR.fromJSON %>+attrIndex]= fromJsonCb if fromJsonCb= @fromJSON
		return
	# Compile DB
	_compileDB= (schema, attr, attrIndex, prototype)->
		# Add to virtual attributes
		if @virtual
			schema[<%=SCHEMA_ATTR.flags %>+attrIndex]|= <%-SCHEMA.VIRTUAL %>	# debug purpose
			(schema[<%=SCHEMA.virtuals %>] ?= []).push attr
			needsProto= yes
		else if @virtual is no
			schema[<%=SCHEMA_ATTR.flags %>+attrIndex]&= <%-~SCHEMA.VIRTUAL %>	# debug purpose
			if virtualAttrs= schema[<%=SCHEMA.virtuals %>]
				_arrRemove virtualAttrs, attr
		# ToDB
		if toDBCb= @toDB
			schema[<%-SCHEMA_ATTR.toDB %>+attrIndex]= toDBCb
			if arr= schema[<%= SCHEMA.toDB %>]
				_arrRemove arr, attr, 2
			else
				arr= schema[<%= SCHEMA.toJSON %>]= []
			arr.push attr, toDBCb
			needsProto= yes
		# ToDB cb
		if needsProto
			# CB
			_toDBWrapper= -> _toWrapper(this, schema[<%=SCHEMA.virtuals %>], schema[<%= SCHEMA.toDB %>])
			# Add
			for wrp in ModelClass.TO_DB
				_defineProperty prototype, wrp,
					value: _toDBWrapper
					configurable: yes
		# fromDB
		schema[<%= SCHEMA_ATTR.fromDB %>+attrIndex]= fromDbCb if fromDbCb= @fromDB
		return
	# Compiler
	return (schema, attr, attrIndex, prototype)->
		_compileJSON.call this, schema, attr, attrIndex, prototype
		_compileDB.call this, schema, attr, attrIndex, prototype
		return


# DEFAULT VALUE: Set a default value when parsing from JSON
.addDirective 'default', (mixed)->
	@type?= ModelClass._types.Mixed # Set type to "Mixed" if not yeat set
	@default= mixed
	return
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	if (fx= @default)?
		schema[<%=SCHEMA_ATTR.default %>+attrIndex]= fx
	return

# GETTER - SETTER
.addDirective 'getter', 'function', (fx)->
	@getOnce= @method= @alias= null
	@get= fx
	return
.addDirective 'getOnce', 'function', (fx)->
	@get= @method= @alias= null
	@getOnce= fx
	return
.addDirective 'setter', 'function', (fx)->
	@method= @alias= null
	@set= fx
	return
.addDirective 'alias', 'string', (attrName)->
	@getOnce= @get= @set= @method= null
	@alias= attrName
	return
.addDirective 'method', 'function', (method)->
	@get= @set= @getOnce= @alias= null
	@method= method
	return
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	# GET ONCE
	if fx= @getOnce
		# schema[<%=SCHEMA_ATTR.getOnce %>+attrIndex]= fx	# debug purpose
		_defineProperty prototype, attr,
			configurable: on
			get: ->
				v= fx.call this
				_defineProperty this, attr,
					value: v
					configurable: on
					enumerable: on
					writable: on
				return v
	# Getter
	else if fx= @get
		# schema[<%=SCHEMA_ATTR.getter %>+attrIndex]= fx	# debug purpose
		_defineProperty prototype, attr,
			get: fx
			configurable: on
	# Setter
	if fx= @set
		# schema[<%=SCHEMA_ATTR.setter %>+attrIndex]= fx	# debug purpose
		_defineProperty prototype, attr,
			set: fx
			configurable: on
	# Method
	if fx= @method
		# schema[<%=SCHEMA_ATTR.method %>+attrIndex]= fx	# debug purpose
		_defineProperty prototype, attr,
			value: fx
			configurable: on
	# Alias
	if fx= @alias
		# schema[<%=SCHEMA_ATTR.alias %>+attrIndex]= fx	# debug purpose
		_defineProperty prototype, attr,
			get: -> @[fx]
			set: (data) ->
				@[fx]= data
				return 
			configurable: on
	return

###*
 * Asserts
 * @example
 * 		assert(7)
 * 		assert(true)
 * 		assert(88, 'Illegal value')
 * TODO add @assertVl
###
.addDirective 'asserts', 'object', (obj)->
	# check format
	for k,v of obj
		throw new Error "Expected #{k} to be object" unless typeof v is 'object' and v
		throw new Error "Expected function #{k}.assert" unless typeof v.assert is 'function'
	# save
	_assign @asserts, obj
	return
.addDirective 'assert', (mixed, errMsg)->
	asserts= @assertVl
	if typeof mixed is 'function'
		@assertFxes.push null, null, mixed, errMsg
	else if typeof mixed is 'object' and mixed
		asserts[k]= [v, errMsg] for k,v of mixed
	else
		asserts.value= [mixed, errMsg]
	return
.addDirective 'length', (mixed, errMsg)-> @assertVl.length= [mixed, errMsg] 
.addDirective 'lt', (mixed, errMsg)-> @assertVl.lt= [mixed, errMsg] 
.addDirective 'lte', (mixed, errMsg)-> @assertVl.lte= [mixed, errMsg]
.addDirective 'gt', (mixed, errMsg)-> @assertVl.gt= [mixed, errMsg] 
.addDirective 'gte', (mixed, errMsg)-> @assertVl.gte= [mixed, errMsg]
.addDirective 'min', (mixed, errMsg)-> @assertVl.gte= [mixed, errMsg]
.addDirective 'max', (mixed, errMsg)-> @assertVl.lte= [mixed, errMsg]
.addDirective 'match', (regex, errMsg)->
	throw new Error 'Expected RegExp as argument' unless regex instanceof RegExp
	@assertVl.match= [regex, errMsg]
	return
.addDirective 'pathMatches', (regex, errMsg)->
	throw new Error 'Expected RegExp as argument' unless regex instanceof RegExp
	@assertVl.pathMatches= [regex, errMsg]
	return
.compileAttrDirective do ->
	# Assert equals
	_assertEquals= (data, param)-> data is param
	_assertMessage= (msg, cmp)->
		(data, param, key, parent, path)->
			unless cmp data, param, key, parent
				throw msg.replace('#{path}', path.join('.')).replace('#{param}', param)
			true
	# Interface
	return (schema, attr, attrIndex, prototype)->
		assertions= schema[<%=SCHEMA_ATTR.asserts %>+attrIndex] or []
		asserts= @asserts
		for k,arr of @assertVl
			param= arr[0]
			msg= arr[1]
			# check param
			if k is 'value'
				if typeof param is 'function'
					cmp= param
					param= null
				else
					cmp= _assertEquals
			else
				if av= asserts[k]
					av.param? param
					cmp= av.assert
					msg= av.msg
					if typeof msg is 'string'
						cmp= _assertMessage msg, cmp
				else
					throw new Error "Unsupported assert <#{k}> for type #{@typeName}"
			# push
			_arrRemove assertions, k, 4
			assertions.push k, param, cmp, msg
		# Push assert functions
		assertions.push v for v in @assertFxes
		# [assertKey, assertParam, assertCompare(currentObj, param), errMsg]
		schema[<%=SCHEMA_ATTR.asserts %>+attrIndex]= assertions
		return


# PIPELINE
.addDirective 'pipe', 'function', (fx)-> @pipe.push fx
.addDirective 'pipeOnce', 'function', (fx)->
	@pipe.push fx
	@pipeOnce.push fx
	return
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	# prepare pipe
	pipe= schema[<%=SCHEMA_ATTR.pipe %>+attrIndex] or []
	pipe.push el for el in @pipe
	# remove cb that should aprears once
	pipeOnceQ= @pipeOnce
	if pipeOnceQ.length
		pipe= pipe.filter (el, i)-> (el not in pipeOnceQ) or (pipe.indexOf(el) is i)
	# add to schema
	schema[<%=SCHEMA_ATTR.pipe %>+attrIndex]= pipe
	return

# Prototype
.addDirective 'proto', 'object', (proto)-> _assign @proto, proto if proto
# .compileAttrDirective (schema, attr, attrIndex, prototype)->
# 	_assign prototype, @proto
# 	return




