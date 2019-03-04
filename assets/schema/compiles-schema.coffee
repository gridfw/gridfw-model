
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
	# convert to descriptor
	nestedObj = Model.value nestedObj unless _owns nestedObj, DESCRIPTOR
	# create compiled schema
	nestedDescriptor = nestedObj[DESCRIPTOR]
	# check for convertion override
	scType = compiledSchema[<%= SCHEMA.schemaType %>]
	if typeof scType is 'number'
		# is Object
		if scType is 1
			throw new Error "compileNested>> Illegal object override at: #{path.join '.'}" unless nestedDescriptor.type is _ModelTypes.Object
		# is Array
		else if scType is 2
			throw new Error "compileNested>> Illegal array override at: #{path.join '.'}" unless nestedDescriptor.type is _ModelTypes.Array
		# uncknown
		else
			throw new Error "compileNested>> Unknown type: #{scType}"
	
	# apply nested compile
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
	compiledSchema[<%= SCHEMA.schemaType %>] = 1 # uncompiled object
	proto = compiledSchema[<%= SCHEMA.proto %>] ?= _create _plainObjPrototype
	# go through object attributes
	attrPos = Math.max <%= SCHEMA.sub %>, compiledSchema.length
	for attrN, attrV of nestedDescriptor.nestedObj
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
			# compile: (attr, schema, proto, attrIndex)
			for comp in _descriptorCompilers
				comp.call attrV, attrN, compiledSchema, proto, attrIndex
			# next schema
			nxtSchema = compiledSchema[attrIndex + <%= SCHEMA.attrSchema %>]
			if nxtSchema
				# nested object
				if nxtSchema[<%= SCHEMA.schemaType %>] is 1
					throw new Error 'Nested obj required' unless attrV.nestedObj
					seekQueue.push attrV.nestedObj, nxtSchema, path.concat attrN
				# nested array
				else if nxtSchema[<%= SCHEMA.schemaType %>] is 2
					arrSchem = nxtSchema[<%= SCHEMA.listSchema %>]
					if arrSchem
						throw new Error 'Nested obj required' unless attrV.arrItem
						seekQueue.push attrV.arrItem, arrSchem, path.concat attrN, '*'
				# unknown
				else
					throw new Error "Unknown schema type: #{nxtSchema[<%= SCHEMA.schemaType %>]}"
		catch err
			errors.push
				path: path.concat attrN
				error: err
	# final adjustements
	for comp in _descriptorFinally
		try
			comp compiledSchema, proto
		catch e
			errors.push
				path: path
				error: err
	return
###*
 * Compile nested array
###
_compileNestedArray = (nestedDescriptor, compiledSchema, path, seekQueue, errors)->
	throw new 'Inexpected array schema' unless _owns nestedDescriptor, 'arrItem'
	compiledSchema[<%= SCHEMA.schemaType %>] = 2 # uncompiled Array
	compiledSchema[<%= SCHEMA.proto %>] ?= nestedDescriptor.arrProto
	
	# item type
	arrItem = nestedDescriptor.arrItem
	if arrItem
		arrItem= arrItem[DESCRIPTOR]
		tp= compiledSchema[<%= SCHEMA.listType %>] = arrItem.type
		compiledSchema[<%= SCHEMA.listCheck %>] = tp.check
		compiledSchema[<%= SCHEMA.listConvert %>] = tp.convert
		# nested object or array
		if arrItem.type in [_ModelTypes.Object, _ModelTypes.Array]
			arrSchem = compiledSchema[<%= SCHEMA.listSchema %>] ?= [] #new Array <%= SCHEMA.sub %>
			# add to queue
			seekQueue.push arrItem.arrItem || arrItem.nestedObj, arrSchem, path.concat '*'
		else
			arrSchem = null
		compiledSchema[<%= SCHEMA.listSchema %>]= arrSchem
	return
