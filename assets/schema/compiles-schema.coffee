
### compile schema ###
_compileSchema = (schema, errors)->
	# prepare schema
	throw new Error "Illegal argument" unless schema and typeof schema is 'object'
	
	# compiled schema, @see schema.template.js for more information
	compiledSchema = new Array <%= SCHEMA.attrPropertyCount %>
	# extensibility
	compiledSchema[<%= SCHEMA.extensible %>] = if schema[DESCRIPTOR]?.extensible then on else off

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
	compiledSchema[<%= SCHEMA.schemaType %>] = 1 # uncompiled object
	proto = compiledSchema[<%= SCHEMA.proto %>] = _create _plainObjPrototype
	# go through object attributes
	attrPos = <%= SCHEMA.sub %>
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
			# next schema
			nxtSchema = compiledSchema[attrPos + <%= SCHEMA.attrSchema %>]
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
			# next attr position
			attrPos += <%= SCHEMA.attrPropertyCount %>
		catch err
			errors.push
				path: path.concat attrN
				error: err
###*
 * Compile nested array
###
_compileNestedArray = (nestedDescriptor, compiledSchema, path, seekQueue, errors)->
	throw new 'Inexpected array schema' unless _owns nestedDescriptor, 'arrItem'
	compiledSchema[<%= SCHEMA.schemaType %>] = 2 # uncompiled Array
	compiledSchema[<%= SCHEMA.proto %>] = nestedDescriptor.arrProto
	# item
	arrItem = @arrItem
	tp = compiledSchema[<%= SCHEMA.listType %>] = arrItem.type
	compiledSchema[<%= SCHEMA.listCheck %>] = tp.check
	compiledSchema[<%= SCHEMA.listConvert %>] = tp.convert
	# nested object or array
	if arrItem.type in [_ModelTypes.Object, _ModelTypes.Array]
		arrSchem = compiledSchema[<%= SCHEMA.listSchema %>] = new Array <%= SCHEMA.sub %>
		seekQueue.push arrItem.arrItem || arrItem.nestedObj, arrSchem, path.concat '*'
	return

