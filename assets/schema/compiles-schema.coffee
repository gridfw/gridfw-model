###*
 * @private
 * compile schema
 * @param  {[type]} schema [description]
 * @param  {[type]} compiledSchema [description]
 * @return Error list
###
_compileSchema = (schemaArch, schema)->
	errors = []

	seekQueue = [schema, schemaArch, []] # shema, schemaArch, path
	seekQueueIndex = 0
	while seekQueueIndex < seekQueue.length
		# load from queue
		schema= seekQueue[seekQueueIndex++]
		schemaArch= seekQueue[seekQueueIndex++]
		path= seekQueue[seekQueueIndex++]
		# compile
		try
			# get descriptor
			descriptor= schemaArch[DESCRIPTOR]
			unless descriptor
				schemaArch= Model.value schemaArch
				descriptor= schemaArch[DESCRIPTOR] 
			# compile descriptor
			# compile: index, (value, descriptor, schema)
			descrpI = 0
			descrpLen= _descriptorCurrentCompilers.length
			while descrpI < descrpLen
				idx= _descriptorCurrentCompilers[descrpI++]
				fx= _descriptorCurrentCompilers[descrpI++]
				vl= descriptor[idx]
				unless vl is undefined
					fx vl, descriptor, schema

			# attr position
			lastAttrPos= previousPos = Math.max <%= SCHEMA.sub %>, schema.length
			# copy attributes
			nested= descriptor[<%= SCHEMA_DESC.nested %>]
			schemaType= schema[<%= SCHEMA.schemaType %>]
			if schemaType is <%= SCHEMA.OBJECT %>
				for attrN, attrV of nested
					# check for attribute already exists and set it if not
					attrI= <%= SCHEMA.sub %>
					found= no
					while attrI < previousPos
						if schema[attrI] is attrN
							found= yes
							break
						attrI+= <%= SCHEMA.attrPropertyCount %>
					unless found
						attrI= lastAttrPos
						lastAttrPos += <%= SCHEMA.attrPropertyCount %>
						schema[lastAttrPos-1] = null # allocate all needed space
					# compile attributes
					#=include compile-schema-attr.coffee
			else if schemaType is <%= SCHEMA.LIST %>
				attrI= previousPos
				attrV= nested
				attrN= '*'
				#=include compile-schema-attr.coffee
			else
				throw new Error "Illegal schema type: #{schemaType}"
		catch err
			errors.push
				path: path
				at: 'compile schema'
				error: err
	# return errors
	return errors