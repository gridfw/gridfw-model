###*
 * Add new types
###
@addType: do ->
	# Define descriptor
	_defineDescriptor= (descriptor)->
		->
			@type= descriptor
			return
	# interface
	return (name, descriptor)->
		try
			throw 'Illegal arguments' unless arguments.length is 2
			throw 'Illegal descriptor' unless descriptor= descriptor[DESC_SYMB]
			# Compile descriptor
			descriptor= _compileAttrDescriptor descriptor
			# Iterate
			name= [name] unless _isArray name
			for el, i in name
				if typeof el is 'string'
					throw "Type already defined" if @_types[el]
					desc= @_types[el]= {...descriptor, typeName: el, fx: no}
					@addDirective el, _defineDescriptor desc
				else if typeof el is 'function'
					throw "Type already set ##{i}: #{el.name}" if @_typesFx.has(el)
					@_typesFx.set el, {...descriptor, typeName: el.name, fx: yes}
				else
					throw "Illegal type name ##{i}"
			return this # chain
		catch err
			err= new Error "AddType>> #{err}" if typeof err is 'string'
			throw err


