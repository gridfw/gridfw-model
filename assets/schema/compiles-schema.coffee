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
	`r: //`
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
				schemaArch= ModelD.value schemaArch
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
					try
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
					catch err
						errors.push
							path: path.concat attrN
							at: 'Compile Object Attrs'
							error: err
						`break r;`
			else if schemaType is <%= SCHEMA.LIST %>
				try
					attrI= <%= SCHEMA.sub %>
					attrV= nested
					attrN= '*'
					#=include compile-schema-attr.coffee
				catch err
					errors.push
						path: path.concat attrN
						at: 'Compile List'
						error: err
					`break r;`
			else
				throw new Error "Illegal schema type: #{schemaType}"
			# final adjustements
			for comp in _descriptorFinally
				try
					comp schema
				catch err
					errors.push
						path: path
						at: 'Final adjustements'
						error: err
		catch err
			errors.push
				path: path
				at: 'Compile schema'
				error: err
	# return errors
	return errors