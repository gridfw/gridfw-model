# Directive wrapper
_directiveWrapper= (cb)->
	->
		# Current object
		obj= if _has this, 'all' then Model.Mixed else this # Model
		# cb
		cb.apply this, arguments
		return obj

###*
 * Add directive
 * Model.addDirective('directiveName', )
###
_defineProperty Model, 'addDirective', value: (directiveName, cbParamType, cb)->
	# names
	if Array.isArray directiveName
		args= Array.from arguments
		for el in directiveName
			args[0]= el
			@addDirective.apply this, args
		return this # chain
	# Checks
	try
		throw "Expected string as name" unless typeof directiveName is 'string'
		throw "Reserved name: #{directiveName}" if _has this, directiveName
		argLen= arguments.length
		if argLen is 2
			cb= cbParamType
			cbParamType= null
		# Checks
		throw 'Illegal arguments' unless typeof cb is 'function'
		throw 'Illegal cb signature' unless cb.length is argLen-2
		# When cb has param
		switch argLen
			when 2
				_defineProperty this, directiveName, get: _directiveWrapper cb
			when 3
				if cbParamType
					_cb= cb
					cb= (param)->
						throw new Error "#{directiveName}>> Expected #{cbParamType}" unless typeof param is cbParamType
						_cb.call this, param
						return
				_defineProperty this, directiveName, value: _directiveWrapper cb
			else
				throw "Wrong directive syntax: #{directiveName}"
		this # chain
	catch err
		err= new Error "AddDirective>> #{err}" if typeof err is 'string'
		throw err