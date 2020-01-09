###*
 * Define descriptor
###
_defineDescriptor= (k, v)->
	throw new Error "Expected function for: #{k}" unless typeof v is 'function'
	# interface
	switch v.length
		when 0
			throw new Error "Illegal function at: #{k}"
		# getter
		when 1
			_defineProperty ModelD, k, get: _defineDescriptorWrapper v
		# function
		else
			_defineProperty ModelD, k, value: _defineDescriptorWrapper v
	return
###*
 * Define descriptors
###
_defineDescriptors= (descriptors)->
	for k,v of descriptors
		_defineDescriptor k, v
	return
# compiler
_descriptorCurrentCompilers = [] # set of descriptor compilers
_defineCurrentSchemaCompiler= (index, cb)->
	_descriptorCurrentCompilers.push index, cb
	return
# compiler
_descriptorCompilers = [] # set of descriptor compilers
_defineParentSchemaCompiler= (index, cb)->
	_descriptorCompilers.push index, cb
	return

# descriptor check
_descriptorChecks = [] # set of descriptor compilers
_descriptorCheck= (cb)->
	_descriptorChecks.push cb
	return

# finally check
_descriptorFinally = [] # final adjustements
_defineDescriptorFinally= (cb)->
	_descriptorFinally.push cb
	return

# schema wrapper
_defaultDescriptor = ->
	# create descriptor
	desc = []
	# return schema descriptor
	obj = _create ModelD,
		[DESCRIPTOR]: value: desc
	return obj
_defineDescriptorWrapper= (fx)->
	->
		# check arguments count
		reqArgs = fx.length - 1
		throw new Error "Expected #{reqArgs} arguments" unless arguments.length is reqArgs
		# descriptor
		dsrp= @[DESCRIPTOR]
		if dsrp
			desc= this
		else
			desc= _defaultDescriptor()
			dsrp= desc[DESCRIPTOR]
		# exec fx
		fx dsrp, arguments...
		#TODO add debug 
		# Chain
		return desc
