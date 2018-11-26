
###*
 * Define descriptor
 * @param {object} options.get	- descriptors using GET method
 * @param {object} options.fx	- descriptors using functions
 * @param {function} options.compile	- compilation of result
###
_descriptorCompilers = [] # set of descriptor compilers
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
	return
### wrapper ###
_defaultDescriptor = ->
	# create descriptor
	desc = _create null
	# return schema descriptor
	obj = _create _schemaDescriptor,
		[DESCRIPTOR]: value: desc
	desc._ = obj
	return obj
_defineDescriptorWrapper = (fx) ->
	->
		desc = if this is Model then _defaultDescriptor() else this
		# exec fx
		fx.apply desc[DESCRIPTOR], arguments
		# chain
		desc

	