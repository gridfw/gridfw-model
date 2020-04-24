###*
 * Basic type: Mixed
###
Mixed= ()->
	result= _create ModelPrototype
	result[DESC_SYMB]=
		format		: 0	# SCHEMA.ATTRIBUTE, SCHEMA.OBJECT, SCHEMA.LIST, SCHEMA.MAP
		model		: null # when set a new model
		type		: null # parent type
		typeName	: null
		check		: null
		convert		: null
		# 
		pipe		: [] # pipeline
		pipeOnce	: [] # pipeOnce
		proto		: {} # nested prototype (of nested object or list)
		# 
		nested		: null	# nested Object, list or map
		key			: null # Key, when map
		freeze		: null	# @default: false
		null		: null	# @default: true
		json		: null	# @default: 0
		toJSON		: null
		fromJSON	: null
		virtual		: null	# @default: no
		toDB		: null
		fromDB		: null
		alias		: null
		getOnce		: null
		get			: null
		set			: null
		method		: null
		# Asserts
		assertVl	: {}	# assert methods
		asserts		: {}	# assert values
		assertFxes	: []	# assert functions
	return result

###*
 * Compile attributes descriptor
 * @private
###
_compileAttrDescriptor= (desc)->
	if type= desc.type
		desc.typeName	?= type.typeName
		desc.check		?= type.check
		desc.convert	?= type.convert
		# flags
		desc.freeze		?= type.freeze
		desc.null		?= type.null
		# JSON
		desc.json		?= type.json
		desc.toJSON		?= type.toJSON
		desc.fromJSON	?= type.fromJSON
		# DB
		desc.virtual	?= type.virtual
		desc.toDB		?= type.toDB
		desc.fromDB		?= type.fromDB
		# Pipes
		if vl= type.pipe
			target=[]
			target.push el for el in vl
			if vl= desc.pipe
				target.push el for el in vl
			desc.pipe= target
		if vl= type.pipeOnce
			target=[]
			target.push el for el in vl
			if vl= desc.pipeOnce
				target.push el for el in vl
			desc.pipeOnce= target
		# Proto
		desc.proto= _assign {}, type.proto, desc.proto
		# Asserts
		desc.assertVl= _assign {}, type.assertVl, desc.assertVl
		desc.asserts= _assign {}, type.asserts, desc.asserts
	return desc