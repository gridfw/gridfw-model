###*
 * Add new directives
 * @example
 * // create static directive for String and 'String'
 * Model.directive String, Model.check(fx).convert(fx)
 *
 * // create dynamic directive
 * Model.directive 'max', (max)-> Model.assert max: max
###
_defineProperties _schemaDescriptor,
	# create directive
	directive: value: (name, cb)->
		directives = @[DIRECTIVES] ?= _create null
		# string name
		if typeof name is 'string'
			strName= name
		else if typeof name is 'function'
			strName= name.name
		# check not already set
		throw new Error "Directive already set: #{strName}" if _owns _schemaDescriptor, strName
		
		# dynamic descriptor
		if typeof cb is 'function'
			_defineProperty _schemaDescriptor, k, value: ->
				# descriptor
				dsrp= @[DESCRIPTOR]
				if dsrp
					desc= this
				else
					desc= _defaultDescriptor()
					dsrp= desc[DESCRIPTOR]
				# call fx
				ds= cb.apply desc, arguments
				# copy descriptor data
				for v, i in ds
					dsrp[i] = v unless v is undefined
				# chain
				return desc
		# static descritpor
		else if Array.isArray cb
			_defineProperty _schemaDescriptor, strName, get: _defineDescriptorWrapper (desc)->
				for v, i in cb
					desc[i] = v unless v is undefined
				return
		# error
		else
			throw new Error 'Illegal directive descriptor'
		# chain
		this
	# create multiple directive at once
	directives: value: (desc)->
		# chain
		this