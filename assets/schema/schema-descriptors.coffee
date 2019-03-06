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
			_defineProperty _schemaDescriptor, k, get: _defineDescriptorWrapper v
		# function
		else
			_defineProperty _schemaDescriptor, k, value: _defineDescriptorWrapper v
	return
###*
 * Define descriptors
###
_defineDescriptors= (descriptors)->
	for k,v of descriptors
		_defineDescriptors k, v
	return
# compiler
_descriptorCompilers = [] # set of descriptor compilers
_defineCompiler= (index, cb)->
	_descriptorCompilers.push index, cb
	return

# descriptor check
_descriptorchechers = [] # set of descriptor compilers
_descriptorCheck= (cb)->
	_descriptorchechers.push cb
	return

# finally check
_descriptorFinally = [] # final adjustements
_defineDescriptorFinally= (descriptor)->
	_descriptorFinally.push cb
	return

# schema wrapper
_defaultDescriptor = ->
	# create descriptor
	desc = []
	# return schema descriptor
	obj = _create _schemaDescriptor,
		[DESCRIPTOR]: value: desc
	desc[<%= SCHEMA_DESCRIPTOR_K.parent %>]= obj
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

ds= cb.apply desc[1], Array.from(arguments)[1...]