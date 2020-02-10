###*
 * Basic type
###
_defineTypeDirective= (descriptor)->
	->
		obj= if _has this, 'all' then Model.Mixed else this # Model
		obj._type= descriptor
		return obj

###*
 * Add new types to the schema
 * Model.addType('Name', descriptor)
 * Model.addType([names], descriptor)
###
_defineProperties Model,
	_types: value: _create null # Store types
	_typesFx: values: new WeakMap() # store maping functions to descriptors
	addType: value: (name, descriptor)->
		try
			throw 'Illegal arguments' unless arguments.length is 2
			types= @_types # types map
			typesFx= @typesFx # types map
			# Compile descriptor
			throw "Illegal arguments" unless typeof (descriptor is 'object') and descriptor
			# Iterate
			name= [name] unless Array.isArray name
			for el, i in name
				if typeof el is 'string'
					throw "Type already set: #{el}" if _has types, el
					types[el]= descriptor
					# Add directive
					throw "Reserved name: #{el}" if _has this, el
					_defineProperty this, el, get: _defineTypeDirective {...descriptor, _typeName: el}
				else if typeof el is 'function'
					throw "Type already set: #{el}" if typesFx.has el
					typesFx.set el, {...descriptor, _typeName: el.name}
				else
					throw "Illegal type name ##{i}"
			this # chain
		catch err
			err= new Error "AddType>> #{err}" if typeof err is 'string'
			throw err
		