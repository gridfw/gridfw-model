###*
 * Basic type
###
_defineTypeDirective= (descriptor)->
	->
		desc= if _has this, 'all' then Model.Mixed else this # Model
		desc._type= descriptor
		desc._nested= null # reset nested element info
		return desc

# _defineTypeFx= (descriptor)->
# 	desc= Model.Mixed
# 	desc._type= descriptor
# 	return desc

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
			typesFx= @_typesFx # types map
			# Compile descriptor
			throw "Illegal arguments" unless typeof (descriptor is 'object') and descriptor
			# Iterate
			name= [name] unless Array.isArray name
			for el, i in name
				if typeof el is 'string'
					throw "Type already set: #{el}" if _has types, el
					throw "Reserved name: #{el}" if _has this, el
					# Add directive
					descriptor= {...descriptor, _typeName: el}
					types[el]= descriptor
					_defineProperty this, el, get: _defineTypeDirective descriptor
				else if typeof el is 'function'
					throw "Type already set: #{el}" if typesFx.has el
					typesFx.set el, {...descriptor, _typeName: el.name}
				else
					throw "Illegal type name ##{i}"
			this # chain
		catch err
			err= new Error "AddType>> #{err}" if typeof err is 'string'
			throw err
		