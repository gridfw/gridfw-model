###*
 * Directive for nested data
###
list: (mixed)->
	throw new Error 'Expected one argument' unless arguments.length is 1
	self= @List
	desc= self[DESC_SYMB]
	desc.format= <%-SCHEMA.LIST %>
	desc.nested= if mixed then ModelPrototype.value(mixed) else Mixed()
	return self

# MAP
map: (key, value)->
	throw new Error 'Expected two arguments' unless arguments.length is 2
	self= @Map
	desc= self[DESC_SYMB]
	desc.format= <%-SCHEMA.MAP %>
	desc.nested= if value then ModelPrototype.value(value) else Mixed()
	desc.key= if key then ModelPrototype.value(key) else Mixed()
	throw new Error 'Map key must be string or number' if desc.key[DESC_SYMB].nested
	return self

# Value
value: (mixed)->
	throw new Error 'Expected one argument' unless arguments.length is 1
	# prepare
	self= this
	unless desc= @[DESC_SYMB]
		self= Mixed()
		desc= self[DESC_SYMB]
	# When function
	if typeof mixed is 'function'
		# Check if it's a registred function
		if desc2= ModelClass._typesFx.get mixed
			desc.type= desc2
		# else, set as method
		else
			self.method mixed
	# When a list
	else if _isArray mixed
		switch mixed.length
			when 1
				self.list mixed[0]
			when 0
				self.list()
			else
				throw new Error "Expected one type for Array, #{mixed.length} are given."
	# nested object
	else if typeof mixed is 'object' and mixed
		# descriptor
		if mixedDesc= mixed[DESC_SYMB]
			# Copy all non null attributes
			for k of mixedDesc
				if v= mixedDesc[k]
					desc[k]= v
		# Nested object
		else
			self.Object
			desc.nested= mixed
			desc.format= <%-SCHEMA.OBJECT %>
	else
		console.log '---vl', mixed
		throw new Error "Model.value>> Illegal value"
	return self