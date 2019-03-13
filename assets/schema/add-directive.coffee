### Map used functions as directives ###
_fxDirectiveMapper= _create null
###*
 * Add new directives
 * @example
 * // create static directive for String and 'String'
 * Model.directive String, Model.check(fx).convert(fx)
 *
 * // create dynamic directive
 * Model.directive 'max', (max)-> Model.assert max: max
###
_overridDescriptor= (target, src)->
	for v, i in src
		unless v?
			continue
		else if typeof v is 'object' # copy object
			target[i]= _deepClone v
		else
			target[i] = v
	target

_defineProperties _schemaDescriptor,
	# create directive
	directive: value: (name, cb)->
		<%= assertArgsLength('directive', 2) %>
		directives = @[DIRECTIVES] ?= _create null
		# string name
		if typeof name is 'string'
			strName= name
			# check not already set
			throw new Error "Directive already set: #{strName}" if strName of _schemaDescriptor # _owns _schemaDescriptor, strName
		else if typeof name is 'function'
			strName= name.name
			throw new Error "Directive with same name already set: #{strName}" if strName of _schemaDescriptor
			# map function
			_fxDirectiveMapper[strName]= name

		# dynamic descriptor
		if typeof cb is 'function'
			# define
			_defineProperty _schemaDescriptor, strName, value: ->
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
			# map function

		# static descritpor
		else if cb= cb[DESCRIPTOR]
			_defineProperty _schemaDescriptor, strName, get: _defineDescriptorWrapper (desc)->
				_overridDescriptor desc, cb
				return
		# error
		else
			throw new Error "Illegal directive descriptor for: #{strName}"
		# chain
		this
	# create multiple directive at once
	directives: value: (directives)->
		<%= assertArgTypes('directives', 'plain object') %>
		for k,v of directives
			@directive k, v
		# chain
		this


