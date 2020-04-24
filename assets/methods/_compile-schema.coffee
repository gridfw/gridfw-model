###*
 * Compile schema
 * @private
 * @param {Object} schema - Schema descriptor to Add
 * @return {function} model
###
_compileSchema: do ->
	# Compile attributes
	_compileAttr= (nodes, node, nodePath, nodeDescriptor, nodePrototype, attr, attrValue, attrIndex)->
		# Convert to descriptor
		unless desc= attrValue[DESC_SYMB]
			attrValue= ModelPrototype.value attrValue
			desc= attrValue[DESC_SYMB]
		# Compile descriptor
		_compileAttrDescriptor desc
		# do compile
		for compiler in ModelClass._compilers
			compiler.call desc, nodeDescriptor, attr, attrIndex, nodePrototype, node
		# next
		if desc.nested
			nestedDescriptor= nodeDescriptor[<%-SCHEMA_ATTR.nested %>+attrIndex]?= [<%- 'null,'.repeat(SCHEMA.length) %>]
			# Prototype
			if node.format is <%- SCHEMA.ROOT %>
				model= node._model
				nestedDescriptor[<%-SCHEMA.prototype %>]= if desc.format is <%-SCHEMA.LIST %> then model else model.prototype
			# Add to queue
			nodes.push attrValue, nodePath.concat(attr), nestedDescriptor
		else
			nestedDescriptor= nodeDescriptor[<%-SCHEMA_ATTR.nested %>+attrIndex]?= null
		return
	# Compile virtual attributes
	_tmpDescriptor= []
	_compileVirtualAttribute= (nodePrototype, attr, attrDescriptor, node)->
		# Compile descriptor
		_compileAttrDescriptor attrDescriptor
		# do compile
		for compiler in ModelClass._compilers
			compiler.call attrDescriptor, _tmpDescriptor, attr, 0, nodePrototype, node
		_tmpDescriptor.length= 0 # Remove any added value
		return
	# Interface
	return (rootModel, schema)->
		try
			nodePath= []
			# Checks
			throw 'Expected model to be string' unless typeof rootModel is 'string'
			throw 'Expected schema' unless schema
			# ROOT
			schema= @of(rootModel).value schema
			# schema[DESC_SYMB].format= <%-SCHEMA.ROOT %>
			# Prepare none recursive loop
			nodeDescriptor= [<%- 'null,'.repeat(SCHEMA.length) %>]
			nodes= [schema, nodePath, nodeDescriptor] # store none recursive nodes: [node, path, descriptor, node2, path2, ...]
			seekIndex= 0
			maxLoop= @_maxLoop # Maximum seeks
			model= null
			while seekIndex < nodes.length
				# Prevent infinit loops
				throw "Max loop exceeded: #{maxLoop}" if seekIndex >= maxLoop
				# Load data
				nodeSchema		= nodes[seekIndex++]
				nodePath		= nodes[seekIndex++]
				nodeDescriptor	= nodes[seekIndex++]
				throw 'Illegal schema' unless node= nodeSchema[DESC_SYMB]
				# is: OBJECT, LIST or MAP
				nodeDescriptor[<%-SCHEMA.format %>]= node.format
				# if has a new Model
				if modelName= node.model
					# Do not enable to override nested models
					throw "Model override denied at this location" if model and @all[modelName] and node.nested
					model= @_loadModel modelName, node.format
					# link
					linkDescriptor= nodeDescriptor
					linkDescriptor[<%-SCHEMA.format %>]= <%- SCHEMA.LINK %>
					linkDescriptor[<%-SCHEMA.model %>]= model
					linkDescriptor[<%-SCHEMA.linkedTo %>]= nodeDescriptor
					# If already compiled
					if model[SCHEMA_SYMB]
						nodeDescriptor= model[SCHEMA_SYMB]
						# override
						# nodeDescriptor[<%-SCHEMA.format %>]= node.format
						# continue
					else
						nodeDescriptor= [<%- 'null,'.repeat(SCHEMA.length) %>]
						nodeDescriptor[<%-SCHEMA.format %>]= <%- SCHEMA.ROOT %>
						nodeDescriptor[<%-SCHEMA.model %>]= modelName
						model[SCHEMA_SYMB]= nodeDescriptor
						nodeDescriptor[<%-SCHEMA.prototype %>]= model.prototype
						# Link
					# add root node
					node.model= null
					node=
						format: <%- SCHEMA.ROOT %>
						nested: nodeSchema
						freeze: node.freeze
						_model: model
				# Compile Object
				switch node.format
					when <%- SCHEMA.ROOT %>
						throw 'Expected nested object' unless nested= node.nested
						# Prototype
						nodePrototype= nodeDescriptor[<%-SCHEMA.prototype %>]?= {}
						# Compile
						modelName= nodeDescriptor[<%-SCHEMA.model %>]
						_compileAttr nodes, node, nodePath, nodeDescriptor, nodePrototype, '_ROOT', nested, <%-SCHEMA.length %>
						nodeDescriptor[<%-SCHEMA.model %>]= modelName # save model name
					when <%- SCHEMA.OBJECT %>
						throw 'Expected nested object' unless nested= node.nested
						# Prototype
						nodePrototype= nodeDescriptor[<%-SCHEMA.prototype %>]?= {}
						_assign nodePrototype, node.proto
						# Compile attributes
						`k://`
						for k of nested
							nestedAttrIndex= <%-SCHEMA.length %>
							len= nodeDescriptor.length
							# Convert to descriptor
							attrValue= nested[k]
							throw "Illegal value of [#{k}]: #{attrValue}" unless attrValue
							unless desc= attrValue[DESC_SYMB]
								attrValue= nested[k]= ModelPrototype.value attrValue
								desc= attrValue[DESC_SYMB]
							# look for attribute
							while nestedAttrIndex < len
								# if key found
								if nodeDescriptor[nestedAttrIndex] is k
									_compileAttr nodes, node, nodePath, nodeDescriptor, nodePrototype, k, attrValue, nestedAttrIndex
									`continue k`
								# go to next
								nestedAttrIndex += <%-SCHEMA_ATTR.length %>
							# Attribute not found: add new attribute
							if desc.type
								nodeDescriptor.push k<%- ',null'.repeat(SCHEMA_ATTR.length-1) %>
								_compileAttr nodes, node, nodePath, nodeDescriptor, nodePrototype, k, attrValue, len
							else
								_compileVirtualAttribute nodePrototype, k, desc, node
					when <%- SCHEMA.LIST %>
						throw 'Expected nested object' unless nested= node.nested
						# Prototype
						nodePrototype= nodeDescriptor[<%-SCHEMA.prototype %>]?= class extends Array
						nodePrototype= nodePrototype.prototype
						_assign nodePrototype, node.proto
						# Compile
						nodeDescriptor.push null<%- ',null'.repeat(SCHEMA_ATTR.length-1) %> if nodeDescriptor.length is <%-SCHEMA.length %>
						_compileAttr nodes, node, nodePath, nodeDescriptor, nodePrototype, '*', nested, <%-SCHEMA.length %>
					when <%- SCHEMA.MAP %>
						throw 'Expected nested object' unless nested= node.nested
						throw 'Expected key' unless key= node.key
						# Prototype
						nodePrototype= nodeDescriptor[<%-SCHEMA.prototype %>] ?= {}
						_assign nodePrototype, node.proto
						# Compile
						nodeDescriptor.push null<%- ',null'.repeat(2*SCHEMA_ATTR.length-1) %> if nodeDescriptor.length is <%-SCHEMA.length %>
						_compileAttr nodes, node, nodePath, nodeDescriptor, nodePrototype, '{key}', key, <%-SCHEMA.length %>
						_compileAttr nodes, node, nodePath, nodeDescriptor, nodePrototype, '{value}', nested, <%-SCHEMA.length + SCHEMA_ATTR.length %>
					else
						throw "Illegal format: #{node.format}"
			# return model
			return @all[rootModel]
		catch err
			err= "Schema-compiler>> #{err}\nat: #{nodePath.join '.'}" if typeof err is 'string'
			throw err


###*
 * Get/Create new model
 * @private
###
_loadModel: (modelName, format)->
	throw 'Expected model name' unless modelName
	unless model= @all[modelName]
		# Create class
		model= @all[modelName]= if format is <%-SCHEMA.LIST %> then class extends Array else class
		# Rename it
		_defineProperties model,
			name:	value: modelName
			Model:	value: this
		# Copy common interface
		_assign model, MODEL_COMMONS
		_assign model.prototype, INSTANCE_COMMONS
	return model

###*
 * Clone schema
 * @private
###
_cloneSchema: (model)->
	rootClone= []
	nodes= [model[SCHEMA_SYMB], rootClone] # [schema, clone]
	seekIndex= 0
	maxLoop= @_maxLoop # Maximum seeks
	while seekIndex<nodes.length
		# Prevent infinit loops
		throw "Max loop exceeded: #{maxLoop}" if seekIndex >= maxLoop
		# Load data
		node= nodes[seekIndex++]
		clone= nodes[seekIndex++]
		# copy Head
		i=0
		while i< <%-SCHEMA.length %>
			value= node[i++]
			# object
			if _isArray value
				arr= []
				arr.push v for v in value
				value= arr
			clone.push value
		# Prototype
		if clone[<%-SCHEMA.format %>] is <%-SCHEMA.LIST %>
			value= clone[<%-SCHEMA.prototype %>]
			value2= class extends Array
			_assign value2.prototype, value.prototype
			clone[<%-SCHEMA.prototype %>]= value2
		else
			value= clone[<%-SCHEMA.prototype %>]
			clone[<%-SCHEMA.prototype %>]= _assign {}, value
		# copy attributes
		len= node.length
		while i<len
			clone.push node[i++]
		# copy other values
		i= <%-SCHEMA.length %>
		while i < len
			# asserts
			arr= node[<%-SCHEMA_ATTR.asserts %>+i]
			value=[]
			value.push v for v in arr
			clone[<%-SCHEMA_ATTR.asserts %>+i]= value
			# pipe
			arr= node[<%-SCHEMA_ATTR.pipe %>+i]
			value=[]
			value.push v for v in arr
			clone[<%-SCHEMA_ATTR.pipe %>+i]= value
			# nested
			if nested= node[<%-SCHEMA_ATTR.nested %>+i]
				nestedClone= []
				clone[<%-SCHEMA_ATTR.nested %>+i]= nestedClone
				nodes.push nested, nestedClone
			i+= <%-SCHEMA_ATTR.length %>
	# Return
	return rootClone