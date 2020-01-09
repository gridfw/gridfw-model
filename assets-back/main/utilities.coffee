_defineProperties ModelP,
	# ignore properties (used with filters)
	ignoreProps: ->
		ignoredProperties= Array.from arguments
		# return
		(obj)->
			kies= Object.keys result
				.filter (k)-> k not in ignoredProperties
			result= _create null
			_getOwnPropertyDescriptor= Object.getOwnPropertyDescriptor
			for k in kies
				_defineProperty result, k, _getOwnPropertyDescriptor obj, k
			return result
	# filter properties
	filterProps: ->
		filteredProperties= Array.from arguments
		# return
		(obj)->
			kies= Object.keys result
				.filter (k)-> k in filteredProperties
			result= _create null
			_getOwnPropertyDescriptor= Object.getOwnPropertyDescriptor
			for k in kies
				_defineProperty result, k, _getOwnPropertyDescriptor obj, k
			return result