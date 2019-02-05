
###*
 * Fast object convertion
 * from DB or any trusted source
 * No validation will be performed
 * Do not use recursivity for performace purpos and 
 * to avoid possible stack overflow
###
###*
 * Convert instance to Model type
 * used when data is from untrusted source
 * will do validation and any required clean
 * example: JSON from client
 * @param {Object} instance - instance to convert and validate
###
<%
var fxes = ['_fastInstanceConvert', '_instanceConvert'];
for(var i=0, len = fxes.length; i<len; ++i){
	var fxName = fxes[i];
	var isFullCheck= fxName === '_instanceConvert'
%>
<%=fxName %>= (instance)->
	throw new Error "<%=fxName %>: Illegal arguments" unless typeof instance is 'object' and instance
	rootModel = @Model
	# get model
	model = this
	# if generator is sub-Model
	if TYPE_ATTR of instance
		model = rootModel.all[instance[TYPE_ATTR]]
		unless model
			rootModel.warn 'Model-convert', "Unknown model set by '#{TYPE_ATTR}' attribute: #{instance[TYPE_ATTR]}"
			model = this
		# Canceled test below for performance purpose
		# throw new Error "Model [#{generator}] do not extends [#{model}]" unless generator is model or generator.prototype instanceof model
	# Result
	result =
		instance: instance
		errors: []
		warns: []
	# schema
	schema = model[SCHEMA]
	# seek
	seekQueu = [instance, schema, []]
	seekQueuIndex = 0
	while seekQueuIndex < seekQueu.length
		try
			# load args
			obj= seekQueu[seekQueuIndex]
			schema= seekQueu[++seekQueuIndex]
			path= seekQueu[++seekQueuIndex]
			++seekQueuIndex
			_setPrototypeOf obj, null
			schemaType = schema[<%= SCHEMA.schemaType %>]
			# convert Object
			obj[SCHEMA] = schema
			
			### Object operations ###
			if schemaType is <%= SCHEMA.OBJECT %>
				throw new Error 'Expected plain object' if Array.isArray obj
				<% if(isFullCheck){ %>
				# Remove ignored attributes from JSON
				if attrs = schema[<%= SCHEMA.ignoreParse %>]
					for v in attrs
						delete obj[v]
				# remove other attributes if not extensible
				unless schema[<%= SCHEMA.extensible %>]
					# get list of all attributes
					attrs = []
					j = <%= SCHEMA.sub %>
					len = schema.length
					while j < len
						attrs.push schema[j] # push attribute name
						j+= <%= SCHEMA.attrPropertyCount %>
					# delete other attributes
					for k of obj
						delete obj[k] unless k in attrs
				# check for required attributes
				if attrs = schema[<%= SCHEMA.required %>]
					for v in attrs
						unless obj[v]?
							result.error.push
								required: true
								attrName: v
								path: path.join v
								error: 'required'
				<% } %>
				# 
				# go through attributes
				j = <%= SCHEMA.sub %>
				len = schema.length
				while j < len
					# next
					i = j
					j+= <%= SCHEMA.attrPropertyCount %>
					# load attr info
					attrName = schema[i]
					# check for attribute
					continue unless attrName of obj
					attrObj = obj[attrName]
					# continue if is null or undefined
					if attrObj in [undefined, null]
						# delete obj[attrName]
						continue
					# convert type
					try
					<% if(isFullCheck){ %>
						# do check if from JSON
						attrType= schema[i+<%= SCHEMA.attrType %>]
						attrCheck= schema[i+<%= SCHEMA.attrCheck %>]
						attrConvert= schema[i+<%= SCHEMA.attrConvert %>]
						# check / convert
						unless attrCheck attrObj
							attrObj = obj[attrName] = attrConvert attrObj
						# exec assertions: [assertionFx, optionalMessage, ...]
						if asserts = schema[i+<%= SCHEMA.attrAsserts %>]
							for assertfx in asserts
								throw new Error 'Assertion fails' if (assertionFx.call obj, attrObj, attrName) is false
						# Type level assertions
						if (asserts = schema[i+<%= SCHEMA.attrPropertyAsserts %>]) and (typeAssertions = attrType.assertions)
							for k,v of asserts
								if assertfx= typeAssertions[k]
									throw new Error 'Type-assertion fails' if (assertfx.assert attrObj, v) is false
						# apply pipes
						if pipes = schema[i+<%= SCHEMA.attrPipe %>]
							for v in pipes
								attrObj = v.call obj, attrObj, attrName
						obj[attrName] = attrObj
					<% } %>

						# if is plain object, add to next subobject to check
						if typeof attrObj is 'object' and attrObj
							seekQueu.push attrObj, schema[i+<%= SCHEMA.attrSchema %>], (path.concat attrName)
					catch err
						delete ele[attrName]
						result.errors.push
							attrName: attrName
							path: path.concat attrName
							value: attrObj
							error: err
			### List operations ###
			else
				throw new Error 'Expected array' unless Array.isArray obj

			#TODO go through list
			# set prototype of
			_setPrototypeOf obj, schema[<%= SCHEMA.proto %>]
		catch err
			result.errors.push
				path: path
				value: obj
				error: err
			
	# return result
	result
<%
}
%>

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