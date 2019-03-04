
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
var fxes = ['_fastInstanceConvert', '_instanceConvert', '_validate'];
for(var i=0, len = fxes.length; i<len; ++i){
	var fxName = fxes[i];
	var isFullCheck= fxName === '_instanceConvert' || fxName === '_validate';
	var isValidateOnly = fxName === '_validate';
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
	<% if(isFullCheck){ %>
	result =
		doc: instance
		errors: []
		warns: []
	<% } %>
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
			schemaType = schema[<%= SCHEMA.schemaType %>]
			# convert Object
			
			### Object operations ###
			if schemaType is <%= SCHEMA.OBJECT %>
				throw new Error 'Expected plain object' if Array.isArray obj
				_setPrototypeOf obj, null
				<% if(isFullCheck && !isValidateOnly){ %>
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
						unless k in attrs
							delete obj[k]
							result.warns.push
								attrName: k
								path: path.concat k
								warn: 'Extra attribute'
				<% } %>

				# check for required attributes
				<% if(isFullCheck){ %>
				if attrs = schema[<%= SCHEMA.required %>]
					for v in attrs
						unless obj[v]?
							result.errors.push
								required: true
								attrName: v
								path: path.concat v
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
					<% if(isFullCheck){ %>
					try
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
						<% if(!isValidateOnly){ %>
						if pipes = schema[i+<%= SCHEMA.attrPipe %>]
							for v in pipes
								attrObj = v.call obj, attrObj, attrName
						<% } %>
						obj[attrName] = attrObj

						# if is plain object, add to next subobject to check
						if typeof attrObj is 'object' and attrObj
							seekQueu.push attrObj, schema[i+<%= SCHEMA.attrSchema %>], (path.concat attrName)
					catch err
						<% if(!isValidateOnly){ %>
						delete obj[attrName]
						<% } %>
						result.errors.push
							attrName: attrName
							path: path.concat attrName
							value: attrObj
							error: err
					<% } else { %>
					# if is plain object, add to next subobject to check
					if typeof attrObj is 'object' and attrObj
						seekQueu.push attrObj, schema[i+<%= SCHEMA.attrSchema %>], (path.concat attrName)
					<% } %>
			### List operations ###
			else if schemaType is <%= SCHEMA.LIST %>
				throw 'Expected array' unless Array.isArray obj
				# prepare fxes
				<% if(isFullCheck){ %>
				attrType= schema[<%= SCHEMA.listType %>]
				attrCheck= schema[<%= SCHEMA.listCheck %>]
				attrConvert= schema[<%= SCHEMA.listConvert %>]
				<% } %>
				# go through elements
				listLen = obj.length
				i= 0
				j=0
				while i < listLen
					attrObj= obj[i]
					<% if(isFullCheck){ %>
					try
						# check the type
						unless attrCheck attrObj
							attrObj = attrConvert attrObj
							obj.splice i, 1, attrObj # replace in the array

						# if is plain object, add to next subobject to check
						if typeof attrObj is 'object' and attrObj
							seekQueu.push attrObj, schema[<%= SCHEMA.listSchema %>], (path.concat j)
						# next
						++i
					catch err
						# save error
						result.errors.push
							attrName: j
							path: path.concat j
							value: attrObj
							error: err
						# remove element in the list
						<% if(!isValidateOnly){ %>
						obj.splice i, 1
						listLen = obj.length # recalc obj length
						<% } %>
					finally
						++j
					<% } else { %>
					# if is plain object, add to next subobject to check
					if typeof attrObj is 'object' and attrObj
						seekQueu.push attrObj, schema[<%= SCHEMA.listSchema %>], (path.concat j)
					# next
					++i
					++j
					<% } %>
			### Unsupported schema type ###
			else
				throw new Error 'Illegal schema type'
			# set prototype of
			obj[SCHEMA] = schema
			_setPrototypeOf obj, schema[<%= SCHEMA.proto %>]
		catch err
			console.log '*** got ERROR: ', err
			<% if(isFullCheck){ %>
			result.errors.push
				path: path
				value: obj
				error: err
			<% } else { %>
			throw err
			<% } %>
	
	# return
	<% if(isFullCheck){ %>
	result
	<% } else { %>
	instance
	<% } %>
<%
}
%>

###*
 * Convert instance from database
 * This will not performe any validation
 * Will do any required convertion
###
# add validate to doc
Model.plugin
	model:
		###*
		 * Faster model convertion
		 * no validation will be performed
		 * Convert an instance from DB or any trusted source
		 * Any illegal attribute value will just be escaped
		 * @param  {[type]} instance [description]
		 * @return {[type]}          [description]
		###
		fromDB: _fastInstanceConvert
		###*
		 * From unstrusted source
		 * will performe validations
		 * @type {[type]}
		###
		fromJSON: _instanceConvert
		###*
		 * validate
		###
		validate: _validate