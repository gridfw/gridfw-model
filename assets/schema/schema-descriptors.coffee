
###*
 * Define descriptor
 * @param {object} options.get	- descriptors using GET method
 * @param {object} options.fx	- descriptors using functions
 * @param {function} options.compile	- compilation of result
###
_descriptorCompilers = [] # set of descriptor compilers
_descriptorFinally = [] # final adjustements
_defineDescriptor= (options)->
	# getters
	if 'get' of options
		for k,v of options.get
			_defineProperty _schemaDescriptor, k, get: _defineDescriptorWrapper v
	# functions
	if 'fx' of options
		for k,v of options.fx
			_defineProperty _schemaDescriptor, k, value: _defineDescriptorWrapper v
	# compile
	if 'compile' of options
		_descriptorCompilers.push options.compile
	# final adjustement
	if 'finally' of options
		_descriptorFinally.push options.finally
	return
### wrapper ###
_defaultDescriptor = ->
	# create descriptor
	desc = _create null,
		_pipe: value: []
	# return schema descriptor
	obj = _create _schemaDescriptor,
		[DESCRIPTOR]: value: desc
	desc._ = obj
	return obj
_defineDescriptorWrapper = (fx) ->
	->
		desc = if this is Model then _defaultDescriptor() else this
		# exec fx
		dsrp = desc[DESCRIPTOR]
		fx.apply dsrp, arguments
		# save representation for debug purpose
		if arguments.length
			nm = """#{fx.name}(#{Array.from(arguments).map((e)->
				if typeof e is 'function'
					"[FUNCTION #{e.name||'Unnamed'}]"
				else
					e?.toString?() || typeof e
			).join ', '})"""
		else
			nm = fx.name
		dsrp._pipe.push nm
		# chain
		desc

	