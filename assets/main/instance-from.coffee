###*
 * Convert instance from database
 * This will not performe any validation
 * Will do any required convertion
###
_defineProperties ModelStatics,
	###*
	 * Faster model convertion
	 * no validation will be performed
	 * Convert an instance from DB or any trusted source
	 * Any illegal attribute value will just be escaped
	 * @param  {[type]} instance [description]
	 * @return {[type]}          [description]
	###
	fromDB: value: _fastInstanceConvert
	###*
	 * From unstrusted source
	 * will performe validations
	 * @type {[type]}
	###
	fromJSON: value: _instanceConvert


###*
 * Fast object convertion
 * from DB or any trusted source
 * No validation will be performed
 * Do not use recursivity for performace purpos and 
 * to avoid possible stack overflow
###
_fastInstanceConvert = (instance, model)->
	throw new Error "Illegal arguments" unless typeof instance is 'object' and instance
	# get model
	switch arguments.length
		when 1
			model = this
		when 2
		else
			throw new Error "Illegal arguments"
	# if generator is sub-Model
	if TYPE_ATTR of instance
		model = ModelRegistry[instance[TYPE_ATTR]]
		throw new Error "Unknown model: #{instance[TYPE_ATTR]}" unless model
		# Canceled test below for performance purpose
		# throw new Error "Model [#{generator}] do not extends [#{model}]" unless generator is model or generator.prototype instanceof model
	# schema
	schema = model[SCHEMA]
	# seek
	seekQueu = [instance, schema]
	seekQueuIndex = 0
	while seekQueuIndex < seekQueu.length
		# load args
		instance= seekQueu[seekQueuIndex]
		schema	= seekQueu[++seekQueuIndex]
		++seekQueuIndex
		# convert Object
		obj[SCHEMA] = schema
		_setPrototypeOf obj, schema[<%= SCHEMA.proto %>]
		# go through attributes
		i = <%= SCHEMA.sub %>
		len = schema.length
		while i < len
			# load attr info
			attrName = schema[i]
			attrCheck= schema[++i]
			attrConvert= schema[++i]
			attrSchema= schema[++i]
			++i
			# check for attribute
			continue unless _owns obj, attrName
			attrObj = obj[attrName]
			# continue if is null or undefined
			if attrObj in [undefined, null]
				delete obj[attrName]
				continue
			# convert type
			try
				# check / convert
				unless attrCheck attrObj
					attrObj = obj[attrName] = attrConvert attrObj
				# if is plain object, add to next subobject to check
				if typeof attrObj is 'object' and attrObj
					seekQueu.push attrObj, attrSchema
			catch e
				delete ele[attrName]
				Model.logError 'DB CONV', e
	# return instance
	instance


###*
 * Convert instance to Model type
 * used when data is from untrusted source
 * will do validation and any required clean
 * example: JSON from client
###
_instanceConvert = (instance, model)->
	throw new Error "Illegal arguments" unless typeof instance is 'object' and instance
	# get model
	switch arguments.length
		when 1
			model = this
		when 2
		else
			throw new Error "Illegal arguments"
	# if generator is sub-Model
	if TYPE_ATTR of instance
		model = ModelRegistry[instance[TYPE_ATTR]]
		throw new Error "Unknown model: #{instance[TYPE_ATTR]}" unless model
		# Canceled test below for performance purpose
		# throw new Error "Model [#{model}] do not extends [#{model}]" unless model is model or model.prototype instanceof model
	# schema
	schema = model[SCHEMA]
	# seek
	seekQueu = [instance, schema]
	seekQueuIndex = 0
	while seekQueuIndex < seekQueu.length
		# load args
		instance= seekQueu[seekQueuIndex]
		schema	= seekQueu[++seekQueuIndex]
		++seekQueuIndex
		# convert Object
		obj[SCHEMA] = schema
		_setPrototypeOf obj, schema[<%= SCHEMA.proto %>]
		# go through attributes
		i = <%= SCHEMA.sub %>
		len = schema.length
		while i < len
			# load attr info
			attrName = schema[i]
			attrCheck= schema[i+1]
			attrConvert= schema[i+2]
			attrSchema= schema[i+3]
			i += SCHEMA_COUNT
			# check for attribute
			continue unless _owns obj, attrName
			attrObj = obj[attrName]
			# continue if is null or undefined
			if attrObj in [undefined, null]
				delete obj[attrName]
				continue
			# convert type
			try
				# check / convert
				unless attrCheck attrObj
					attrObj = obj[attrName] = attrConvert attrObj
				# if is plain object, add to next subobject to check
				if typeof attrObj is 'object' and attrObj
					seekQueu.push attrObj, attrSchema
			catch e
				delete ele[attrName]
				Model.logError 'DB CONV', e
	# return instance
	instance
