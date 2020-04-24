###*
 * Add new directives
 * @param  {String, Array}   directiveName - name of the directive and aliases
 * @param  {Array}   params   - List of params and it's types
 * @param  {Function} cb            - Callback
 * @return self
###
@addDirective: do ->
	###* Directive wrapper ###
	_wrap= (cb)->
		->
			# Current object
			self= this
			unless desc= self[DESC_SYMB]
				self= Mixed()
				desc= self[DESC_SYMB]
			# cb
			cb.apply desc, arguments
			return self
	###* Assert params ###
	_assertParam= (cb, paramType)->
		(param)->
			throw new Error 'Illegal arguments' if arguments.length > 1
			throw new Error "Expected #{paramType}" if paramType and not (typeof param is paramType)
			# Cb
			return cb.apply this, arguments
			
	_assertParams= (cb, params)->
		->
			throw new Error 'Illegal arguments' if arguments.length > params.length
			for p,i in params
				throw new Error "Expected #{p}" if p and not (typeof arguments[i] is p)
			# Cb
			return cb.apply this, arguments

	###* Apply add ###
	_add= (directiveName, desc)->
		throw 'First arg expected String or Array<String>' unless typeof directiveName is 'string'
		throw "Reserved name: #{directiveName}" unless typeof ModelPrototype[directiveName] is 'undefined'
		_defineProperty ModelPrototype, directiveName, desc
		return
	###* Interface ###
	return (directiveName, params, cb)->
		try
			# Check args
			if arguments.length is 2
				[params, cb]= [null, params]
			else unless arguments.length is 3
				throw new Error 'Illegal arguments'
			throw new Error "Expected cb as function" unless typeof cb is 'function'
			# Wrap function
			# Add as function
			if cb.length
				cb= _wrap cb
				# Check args
				if params
					if typeof params is 'string'
						cb= _assertParam cb, params
					else if _isStringArray params
						cb= _assertParams cb, params
					else
						throw new Error 'Illegal params checker'
				# add
				cb= value: cb
			else
				throw new Error 'Illegal params checker' if params
				cb= get: _wrap cb

			# Apply
			if _isArray directiveName
				_add name, cb for name in directiveName
			else
				_add directiveName, cb
		catch err
			err= new Error "Add-directive>> #{err}" if typeof err is 'string'
			throw err
		return this # chain