###*
 * Predifined directives
###
Model
# TYPE
.addDirective 'check', 'function', (fx)-> @_check= fx
.addDirective 'convert', 'function', (fx)-> @_convert= fx
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	schema[<?=SCHEMA_ATTR.check ?>+attrIndex]= @_check
	schema[<?=SCHEMA_ATTR.convert ?>+attrIndex]= @_convert
	return

# Require
.addDirective 'required', -> @_required= yes
.addDirective 'optional', -> @_required= no
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	schema[<?=SCHEMA_ATTR.required ?>+attrIndex]= !!@_required
	return

# Freeze
.addDirective 'freeze', -> @_freeze= yes
.addDirective 'extensible', -> @_freeze= no
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	schema[<?=SCHEMA_ATTR.required ?>+attrIndex]= !!@_freeze
	return

# NULL
.addDirective 'null', -> @_null= yes
.addDirective 'notNull', -> @_null= no
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	schema[<?=SCHEMA_ATTR.null ?>+attrIndex]= !!@_null
	return

# JSON
.addDirective 'jsonEnable', -> @_json= 0					# 0b00
.addDirective ['jsonIgnore', 'ignoreJSON'], -> @_json= 3	# 0b11
.addDirective 'jsonIgnoreParse', -> @_json= 2				# 0b10
.addDirective 'jsonIgnoreStringify', -> @_json= 1			# 0b01
.addDirective 'toJSON', 'function', (fx)-> @_toJSON= fx
.addDirective 'fromJSON', 'function', (fx)-> @_fromJSON= fx
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	# checkes
	json= @_json or 0
	schema[<?=SCHEMA_ATTR.json ?>+attrIndex]= json	# debug purpose
	schema[<?=SCHEMA_ATTR.ignoreJsonParse ?>+attrIndex]= !!(json&2) # Ignore data when parsing from JSON
	# ignore when serializing
	if json&1
		(schema[<%= SCHEMA.ignoreJsonAttrs %>] ?= []).push attr
	else if arr= schema[<%= SCHEMA.ignoreJsonAttrs %>]
		_arrRemove arr, attr
	# ToJSON
	if toJsonCb= @_toJSON
		if arr= schema[<%= SCHEMA.toJSON %>]
			_arrRemove arr, attr, 2
		else
			arr= schema[<%= SCHEMA.toJSON %>]= []
		arr.push attr, toJsonCb
	# fromJSON
	if fromJsonCb= @_fromJSON
		if arr= schema[<%= SCHEMA.fromJSON %>]
			_arrRemove arr, attr, 2
		else
			arr= schema[<%= SCHEMA.fromJSON %>]= []
		arr.push attr, fromJsonCb
	# ToJSON cb
	#TODO toJSON cb
	return

# DATABASE
.addDirective ''

# GETTER - SETTER
.addDirective 'default',null, (mixed)-> @_get= mixed
.addDirective 'getter', 'function', (fx)->
	@_getOnce= null
	@_get= fx
	return
.addDirective 'setter', 'function', (fx)-> @_set= fx
.addDirective 'getOnce', 'function', (fx)->
	@_get= null
	@_getOnce= fx
	return
.addDirective 'alias', 'string', (attrName)->
	@_get= -> @[attrName]
	@_set= (data)->
		@[attrName]= data
		return
	return
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	# get once
	if getOnceCb= @_getOnce
		schema[<?=SCHEMA_ATTR.getOnce ?>+attrIndex]= getOnceCb	# debug purpose
		_defineProperty prototype, attr,
			configurable: on
			get: ->
				v= getOnceCb.call this
				_defineProperty this, attr,
					value: v
					configurable: on
					enumerable: on
					writable: on
				return v
	return
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	# Getter
	if fx= @_get
		schema[<?=SCHEMA_ATTR.getter ?>+attrIndex]= fx	# debug purpose
		_defineProperty prototype, attr,
			get: fx
			configurable: on
	# Setter
	if fx= @_set
		schema[<?=SCHEMA_ATTR.setter ?>+attrIndex]= fx	# debug purpose
		_defineProperty prototype, attr,
			set: fx
			configurable: on
	return

###*
 * Asserts
 * @example
 * 		assert(7)
 * 		assert(true)
 * 		assert(88, 'Illegal value')
 * TODO add @_assertVl
###
.addDirective 'asserts', 'object', (obj)->
	# check format
	for k,v of obj
		throw new Error "Expected #{k} to be object" unless typeof v is 'object' and v
		throw new Error "Expected function #{k}.assert" unless typeof v.assert is 'function'
	# save
	@_asserts= obj
	return
.addDirective 'assert', null, ['string', 'undefined'], (mixed, errMsg)->
	asserts= @_assertVl
	if typeof mixed is 'object' and mixed
		asserts[k]= [v, errMsg] for k,v of mixed
	else
		asserts.value= [mixed, errMsg]
	return
.addDirective 'length', null, ['string', 'undefined'], (mixed, errMsg)-> @_assertVl.length= [mixed, errMsg] 
.addDirective 'lt', null, ['string', 'undefined'], (mixed, errMsg)-> @_assertVl.lt= [mixed, errMsg] 
.addDirective 'lte', null, ['string', 'undefined'], (mixed, errMsg)-> @_assertVl.lte= [mixed, errMsg] 
.addDirective 'gt', null, ['string', 'undefined'], (mixed, errMsg)-> @_assertVl.gt= [mixed, errMsg] 
.addDirective 'gte', null, ['string', 'undefined'], (mixed, errMsg)-> @_assertVl.gte= [mixed, errMsg]
.addDirective 'match', RegExp, ['string', 'undefined'], (mixed, errMsg)-> @_assertVl.match= [mixed, errMsg]
.addDirective 'pathMatches', RegExp, ['string', 'undefined'], (mixed, errMsg)-> @_assertVl.pathMatches= [mixed, errMsg]
# Create params
_assertEquals= (data, param)-> data is param
Model.compileAttrDirective (schema, attr, attrIndex, prototype)->
	assertions= []
	asserts= @_asserts or {}
	for k,arr of @_assertVl
		param= arr[0]
		msg= arr[1]
		# check param
		if k is 'value'
			if typeof param is 'function'
				cmp= param
			else
				cmp= _assertEquals
		else
			if av= asserts[k]
				av.param? param
				cmp= av.assert
			else
				throw new Error "Unsupported assert #{k} for type #{@_type.name}"
		# push
		assertions.push k, param, cmp, msg
	# [assertKey, assertParam, assertCompare(currentObj, param), errMsg]
	schema[<?=SCHEMA_ATTR.asserts ?>+attrIndex]= assertions
	return

# PIPELINE
.addDirective 'pipe', 'function', (fx)-> @_pipe.push fx
.addDirective 'pipeOnce', 'function', (fx)->
	@_pipe.push fx
	@_pipeOnce.push fx
	return
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	# get all pipes
	pipes= [@_pipe]
	pipesOnce= [@_pipeOnce]
	p= this
	while p= p.__proto__
		pipes.push p._pipe if p.hasOwnProperty '_pipe'
		pipesOnce.push p._pipeOnce if p.hasOwnProperty '_pipeOnce'
	# prepare pipeOnce
	pipeOnceQ= []
	for el in pipesOnce
		pipeOnceQ.push a for a in el
	# prepare pipe
	pipes.reverse()
	pipe= []
	for el in pipes
		pipe.push a for a in el
	# remove cb that should aprears once
	if pipeOnceQ.length
		pipe= pipe.filter (el, i)-> (el not in pipeOnceQ) or (pipe.indexOf(el) is i)
	# add to schema
	schema[<?=SCHEMA_ATTR.pipe ?>+attrIndex]= pipe
	return


# Prototype
.addDirective 'proto', 'object', (proto)->
	_proto= @_proto
	for k,v of proto
		_proto[k]= v
	return
.compileAttrDirective (schema, attr, attrIndex, prototype)->
	for k,v of @_proto
		prototype[k]= v
	return





