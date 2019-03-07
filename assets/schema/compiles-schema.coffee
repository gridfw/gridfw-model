
###*
 * @private
 * compile schema
 * @param  {[type]} schema [description]
 * @param  {[type]} compiledSchema [description]
 * @return Error list
###
_compileSchema = (schema, compiledSchema)->
	errors = []
	# prepare schema
	throw new Error "Compile Schema>> Illegal argument" unless schema and typeof schema is 'object'

	#  use queu instead of recursivity to prevent
	#  stack overflow and increase performance
	#  queu format: [shema, path, ...]
	seekQueue = [schema, compiledSchema, []]
	seekQueueIndex = 0
	# seek through schema
	while seekQueueIndex < seekQueue.length
		# load data from Queue
		schema		= seekQueue[seekQueueIndex]
		cmpSchema	= seekQueue[++seekQueueIndex]
		path		= seekQueue[++seekQueueIndex]
		++seekQueueIndex
		# compile
		_compileNested schema, cmpSchema, path, seekQueue, errors
	# return errors
	return errors	
			
###*
 * Compile nested object or array
###
# 
_compileNested = (nestedObj, compiledSchema, path, seekQueue, errors)->
	try
		# convert to descriptor
		nestedObj = Model.value nestedObj unless _owns nestedObj, DESCRIPTOR
		# create compiled schema
		nestedDescriptor = nestedObj[DESCRIPTOR]
		# check for convertion override
		scType = compiledSchema[<%= SCHEMA.schemaType %>]
		if typeof scType is 'number'
			# is Object
			if scType is <%= SCHEMA.OBJECT %>
				throw "Illegal object override" unless nestedDescriptor[<%= SCHEMA_DESC.check %>] is _CHECK_IS_OBJECT
			# is Array
			else if scType is <%= SCHEMA.LIST %>
				throw new Error "Illegal array override" unless nestedDescriptor[<%= SCHEMA_DESC.check %>] is _CHECK_IS_LIST
			# uncknown
			else
				throw new Error "Unknown type: #{scType}"
		
		# apply nested compile
		if nestedDescriptor[<%= SCHEMA_DESC.check %>] is _CHECK_IS_OBJECT
			_compileNestedObject nestedDescriptor, compiledSchema, path, seekQueue, errors
		else if nestedDescriptor[<%= SCHEMA_DESC.check %>] is _CHECK_IS_LIST
			_compileNestedArray nestedDescriptor, compiledSchema, path, seekQueue, errors
		else
			throw "Schema could be Object or Array only!"
	catch err
		errors.push
			path: path
			at: 'compileNested'
			error: err
	return
###*
 * Compile nested object
###
_compileNestedObject= (nestedDescriptor, compiledSchema, path, seekQueue, errors)->
	compiledSchema[<%= SCHEMA.schemaType %>] = 1 # uncompiled object
	proto = compiledSchema[<%= SCHEMA.proto %>] ?= _create _plainObjPrototype
	# go through object attributes
	attrPos = Math.max <%= SCHEMA.sub %>, compiledSchema.length
	for attrN, attrV of nestedDescriptor[<%= SCHEMA_DESC.nestedObject %>]
		try
			# check if attribute already exists (case of override)
			attrIndex = 0
			attrI = <%= SCHEMA.sub %>
			while attrI < attrPos
				if compiledSchema[attrI] is attrN
					attrIndex = attrI
					break
				attrI += <%= SCHEMA.attrPropertyCount %>
			unless attrIndex
				attrIndex = attrPos
				attrPos += <%= SCHEMA.attrPropertyCount %>
				compiledSchema[attrIndex + <%= SCHEMA.attrPropertyCount - 1 %>] = null # allocate all needed space
				compiledSchema[attrIndex] = attrN
			# check not Model
			throw new Error "Illegal use of Model" if attrV is Model
			# convert to descriptor
			attrV = Model.value attrV unless _owns attrV, DESCRIPTOR
			# get descriptor
			attrV =attrV[DESCRIPTOR]
			# check descriptor
			for comp in _descriptorchechers
				comp attrV
			# compile: index, (value, attr, schema, proto, attrIndex, descriptor)
			descrpI = 0
			descrpLen= _descriptorCompilers.length
			while descrpI < descrpLen
				idx= _descriptorCompilers[descrpI++]
				fx= _descriptorCompilers[descrpI++]
				vl= attrV[idx]
				if vl isnt undefined
					fx vl, attrN, compiledSchema, proto, attrIndex, attrV
			# next schema
			nxtSchema = compiledSchema[attrIndex + <%= SCHEMA.attrSchema %>]
			if nxtSchema and not compiledSchema[attrIndex + <%= SCHEMA.attrRef %>] # not a reference
				# nested object
				if nxtSchema[<%= SCHEMA.schemaType %>] is <%= SCHEMA.OBJECT %>
					throw new Error 'Nested obj required' unless attrV[<%= SCHEMA_DESC.nestedObject %>]
					seekQueue.push attrV[<%= SCHEMA_DESC.nestedObject %>], nxtSchema, path.concat attrN
				# nested array
				else if nxtSchema[<%= SCHEMA.schemaType %>] is <%= SCHEMA.LIST %>
					arrSchem = nxtSchema[<%= SCHEMA.listSchema %>]
					if arrSchem
						throw new Error 'Nested obj required' unless attrV[<%= SCHEMA_DESC.nestedList %>]
						seekQueue.push attrV[<%= SCHEMA_DESC.nestedList %>], arrSchem, path.concat attrN, '*'
				# unknown
				else
					throw new Error "Unknown schema type: #{nxtSchema[<%= SCHEMA.schemaType %>]}"
		catch err
			errors.push
				path: path.concat attrN
				at: 'compile nested object'
				error: err
	# final adjustements
	for comp in _descriptorFinally
		try
			comp compiledSchema
		catch e
			errors.push
				path: path
				at: 'Final adjustements'
				error: err
	return
###*
 * Compile nested array
###
_compileNestedArray = (nestedDescriptor, compiledSchema, path, seekQueue, errors)->
	throw new 'Inexpected array schema' unless nestedDescriptor[<%= SCHEMA_DESC.nestedList %>]
	compiledSchema[<%= SCHEMA.schemaType %>] = <%= SCHEMA.LIST %> # uncompiled Array
	compiledSchema[<%= SCHEMA.proto %>] ?= nestedDescriptor[<%= SCHEMA_DESC.listProto %>]
	
	# item type
	arrItem = nestedDescriptor[<%= SCHEMA_DESC.nestedList %>]
	if arrItem
		arrItem= arrItem[DESCRIPTOR]
		# tp= compiledSchema[<%= SCHEMA.listType %>] = arrItem.type
		# compiledSchema[<%= SCHEMA.listCheck %>] = tp.check
		# compiledSchema[<%= SCHEMA.listConvert %>] = tp.convert
		compiledSchema[<%= SCHEMA.listCheck %>] = arrItem[<%= SCHEMA_DESC.check %>]
		compiledSchema[<%= SCHEMA.listConvert %>] = arrItem[<%= SCHEMA_DESC.convert %>]
		# nested object or array
		arrSchem = compiledSchema[<%= SCHEMA.listSchema %>]
		if arrItem[<%= SCHEMA_DESC.check %>] in [_CHECK_IS_OBJECT, _CHECK_IS_LIST]
			if arrItem[<%= SCHEMA_DESC.ref %>]
				compiledSchema[<%= SCHEMA.listRef %>]= arrItem[<%= SCHEMA_DESC.ref %>]
				arrSchem= undefined
			else
				arrSchem ?= [] #new Array <%= SCHEMA.sub %>
			# add to queue
			seekQueue.push arrItem[<%= SCHEMA_DESC.nestedList %>] || arrItem[<%= SCHEMA_DESC.nestedObject %>], arrSchem, path.concat '*'
		compiledSchema[<%= SCHEMA.listSchema %>]= arrSchem
	return
