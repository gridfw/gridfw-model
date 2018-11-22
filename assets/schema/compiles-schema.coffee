
### compile schema ###
_compileSchema = (schema)->
	# compiled schema, @see schema.template.js for more information
	compiledSchema = []
	compiledSchema[<%= SCHEMA.proto %>] = _create _plainObjPrototype
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
		# prototype
		proto = compiledSchema[<%= SCHEMA.proto %>]
		# go through all attributes
		for k,v in schema
			# check if function
			if typeof v is 'function'
				# check if registred type
				t = _ModelTypes[v.name]
				if t and t.name is v
					v= Model[v.name]
				# if date.now, set it as default value
				else if v is Date.now
					v= Model.default v
				# else add this function as prototype property
				else
					_defineProperty proto, k, value: v
					continue
			# if it is an array of objects
			else if Array.isArray v
				switch v.length
					when 1
						v = Model.list v[0]
					when 0
						v = Model.list()
					else
						throw new Error "One type is expected for Array, #{v.length} are given at #{path.join '.'}"
			# nested object
			else if typeof v is 'object'
				v = Model.value v unless _owns v, DESCRIPTOR
			else
				throw new Error "Illegal descriptor at: #{path.join '.'}"
			# get descriptor
			v =v[DESCRIPTOR]
			# do operations on prototype
			v.initPrototype proto
			# insert into current compiled schema
			v.pushSchema k, compiledSchema
				
			

