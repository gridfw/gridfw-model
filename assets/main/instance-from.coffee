
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

			### Object operations ###
			if schemaType is <%= SCHEMA.OBJECT %>
				<% var isList= false; %>
				throw new Error 'Expected plain object' if Array.isArray obj
				_setPrototypeOf obj, null

				# full check
				<% if(isFullCheck){ %>

				<% if(!isValidateOnly){ %>
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
				# check attributes
				i = <%= SCHEMA.sub %>
				len = schema.length
				while i < len
					try
						# load attr info
						attrName = schema[i]
						# check for attribute
						if attrName of obj
							# check if ignore when parsing
							<% if(!isValidateOnly){ %>
							if schema[i + <%= SCHEMA.attrIgnoreJSONParsing %>] is yes
								delete obj[attrName]
								continue
							<% } %>
							# check not null
							attrObj= obj[attrName]
							unless attrObj?
								unless schema[i + <%= SCHEMA.attrNull %>] is yes
									<%= isValidateOnly? '' : 'delete obj[attrName]' %>
									if schema[i + <%= SCHEMA.attrRequired %>]
										result.errors.push
											null: true
											required: true
											attrName: attrName
											path: path.concat attrName
											error: 'Required attribute is ' + attrObj
								continue
						else
							if schema[i + <%= SCHEMA.attrRequired %>]
								result.errors.push
									required: true
									attrName: attrName
									path: path.concat attrName
									error: 'required'
							continue
						
						# operations
						#=include instance-from-full-check.coffee
					catch err
						<%= isValidateOnly? '' : 'delete obj[attrName]' %>
						result.errors.push
							attrName: attrName
							path: path.concat attrName
							value: attrObj
							error: err
					finally
						i+= <%= SCHEMA.attrPropertyCount %>
				<% } %>

				# check for nested elements
				i = <%= SCHEMA.sub %>
				len = schema.length
				while i < len
					try
						# get info
						attrName= schema[i]
						attrObj= obj[attrName]
						#=include instance-from-next.coffee
					catch err
						result.errors.push
							attrName: attrName
							path: path.concat attrName
							value: attrObj
							error: err
					# next
					i+= <%= SCHEMA.attrPropertyCount %>


			### List operations ###
			else if schemaType is <%= SCHEMA.LIST %>
				throw 'Expected array' unless Array.isArray obj
				
				# full check
				<% if(isFullCheck){ %>
				attrCheck= schema[<%= SCHEMA.sub + SCHEMA.attrCheck %>]
				attrConvert= schema[<%= SCHEMA.sub + SCHEMA.attrConvert %>]
				i= <%= SCHEMA.sub %>
				j= 0
				attrName= 0
				listLen = obj.length
				while i < listLen
					try
						attrObj= obj[attrName]
						# check not null
						unless attrObj?
							if schema[i + <%= SCHEMA.attrNull %>] is yes
								obj.splice attrName, 1 # remove this value
								continue
						# full check value
						#=include instance-from-full-check.coffee
						# next
						++attrName
					catch err
						# save error
						result.errors.push
							attrName: j
							path: path.concat j
							value: attrObj
							error: err
						# remove element in the list
						<% if(!isValidateOnly){ %>
						obj.splice attrName, 1
						listLen = obj.length # recalc obj length
						<% } %>
					finally
						++j
				<% } %>

				# check for nested elements
				i= <%= SCHEMA.sub %>
				for attrObj, attrName in obj
					try
						#=include instance-from-next.coffee
					catch err
						attrName: attrName
						path: path.concat attrName
						value: attrObj
						error: err
					

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