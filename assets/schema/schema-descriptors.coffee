###*
 * schema descriptors
###
_SchemaDescriptorProto = _create null,
	### init object prototype ###
	initPrototype: value: (proto)->

	### add attr information to compiled schema ###
	pushSchema: value: (attrName, compiledSchema)->
		compiledSchema.push attrName

		type.check # check attribute type
				type.convert # convert attribute type
				v.nested
				v.validate
				v.pipe

###*
 * Define descriptor
 * @param {object} options.get	- descriptors using GET method
 * @param {object} options.fx	- descriptors using functions
 * @param {function} options.compile	- compilation of result
###
_defineDescriptor= (options)->
	# value
	if 'value' of desc
		desc.value = _defineDescriptorWrapper desc.value
	else if 'get' of desc
		desc.get = _defineDescriptorWrapper desc.get
	else
		throw new Error "Illegal arguments"
	# define value
	Object.defineProperty _schemaDescriptor, name, desc


















###*
 * define descriptor
 * @example
 * _defineDescriptor 'decsName', value: ()->
 * _defineDescriptor 'decsName', get:->
###
_schemaDescriptor = _create null
_defineDescriptor =  (name, desc) ->
	# value
	if 'value' of desc
		desc.value = _defineDescriptorWrapper desc.value
	else if 'get' of desc
		desc.get = _defineDescriptorWrapper desc.get
	else
		throw new Error "Illegal arguments"
	# define value
	Object.defineProperty _schemaDescriptor, name, desc

### wrapper ###
_defaultDescriptor = ->
	# create descriptor
	desc = _create _SchemaDescriptorProto,
		asserts: value: []
		rules: value: _create null # validation rules, could be overrided ({max: xxx, min: xxxx})
		pipe: value: [] # pipes
		protoInit: value: new Set() # init prototype functions
	# return schema descriptor
	_create _schemaDescriptor,
		[DESCRIPTOR]: value: desc
_defineDescriptorWrapper = (fx) ->
	->
		desc = if this is Model then _defaultDescriptor() else this
		# exec fx
		fx.apply desc[DESCRIPTOR], arguments
		# chain
		desc