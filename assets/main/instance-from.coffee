
###*
 * Fast object convertion
 * from DB or any trusted source
 * No validation will be performed
 * Do not use recursivity for performace purpos and 
 * to avoid possible stack overflow
###
_fastInstanceConvert = (instance)->
	throw new Error "Illegal arguments" unless typeof instance is 'object' and instance
	rootModel = @Model
	# get model
	model = this
	# if generator is sub-Model
	if TYPE_ATTR of instance
		model = @Model.all[instance[TYPE_ATTR]]
		unless model
			rootModel.warn 'Model-convert', "Unknown model set by '#{TYPE_ATTR}' attribute: #{instance[TYPE_ATTR]}"
			model = this
		# Canceled test below for performance purpose
		# throw new Error "Model [#{generator}] do not extends [#{model}]" unless generator is model or generator.prototype instanceof model
	# schema
	schema = model[SCHEMA]
	# seek
	seekQueu = [instance, schema]
	seekQueuIndex = 0
	while seekQueuIndex < seekQueu.length
		# load args
		obj= seekQueu[seekQueuIndex]
		_setPrototypeOf obj, null
		schema	= seekQueu[++seekQueuIndex]
		++seekQueuIndex
		# convert Object
		obj[SCHEMA] = schema
		# go through attributes
		i = <%= SCHEMA.sub %>
		len = schema.length
		while i < len
			j= i
			# load attr info
			attrName = schema[j]
			attrCheck= schema[++j]
			attrConvert= schema[++j]
			attrSchema= schema[++j]
			i+= <%= SCHEMA.attrPropertyCount %>
			# check for attribute
			continue unless attrName of obj
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
		# set prototype of
		_setPrototypeOf obj, schema[<%= SCHEMA.proto %>]
	# return instance
	instance


###*
 * Convert instance to Model type
 * used when data is from untrusted source
 * will do validation and any required clean
 * example: JSON from client
 * @param {Object} instance - instance to convert and validate
###
_instanceConvert = (instance)->
	throw new Error "Illegal arguments" unless typeof instance is 'object' and instance
	# get model
	model = this
	# if generator is sub-Model
	if TYPE_ATTR of instance
		model = @Model.all[instance[TYPE_ATTR]]
		unless model
			rootModel.warn 'Model-convert', "Unknown model set by '#{TYPE_ATTR}' attribute: #{instance[TYPE_ATTR]}"
			model = this
		# Canceled test below for performance purpose
		# throw new Error "Model [#{model}] do not extends [#{model}]" unless model is model or model.prototype instanceof model
	# schema
	schema = model[SCHEMA]
	# seek
	seekQueu = [instance, schema]
	seekQueuIndex = 0
	while seekQueuIndex < seekQueu.length
		# load args
		obj= seekQueu[seekQueuIndex]
		_setPrototypeOf obj, null
		schema	= seekQueu[++seekQueuIndex]
		++seekQueuIndex
		# convert Object
		obj[SCHEMA] = schema
		# go through attributes
		i = <%= SCHEMA.sub %>
		len = schema.length
		while i < len
			j= i
			# load attr info
			attrName = schema[j]
			attrCheck= schema[++j]
			attrConvert= schema[++j]
			attrSchema= schema[++j]
			i += <%= SCHEMA.attrPropertyCount %>
			# check for attribute
			continue unless attrName of obj
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
		# restore prototype
		_setPrototypeOf obj, schema[<%= SCHEMA.proto %>]
	# return instance
	instance


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