###*
 * Schema template
###
schema=
	# TYPE
	Object: 0
	List: 1

# Object & List descriptor
schemaElement= [
	'format' # schema type: schema.Object or schema.List oe schema.Map
	'prototype' # Element prototype
	# 'extensible' # Do Object is extensible
	'ignoreJsonAttrs' # [] attributes to ignore when serializing as JSON
	'virtuals'	# [] Virtual attributes

	'toJSON'	# [attrName, toJsonCb, ...] to call when serialising as JSON
	'toDB'		# [attrName, toJsonCb, ...] to call when sending to DB (could be async)
]

# Attributes descriptor
schemaAttrs= [
	'name'	# attr name
	'type'	# Ref to attr type
	'convert' # convert function

	###*
	 * FLAGS
	 * 2bits:	JSON
	 * 			0b00: enable
	 * 			0b01: ignore stringify
	 * 			0b10: ignore parse
	 * 			0b11: ignore all
	 * 1bit:	REQUIRED: if the attribute is required
	 * 1bit:	FREEZE: If the subobject is freezed (could not accept other attributes)
	 * 1bit:	VIRTUAL: debug purpose, if this attr is virtual (do not save to DB)
	 * 1bit:	NOT_NULL: Do value could not be null
	###
	'flags' # FLAGS: 2bits => json, 

	'default'	# Default value when parsing from JSON
	
	# TODO
	'fromDB'	# function(key, data, parentObject) - Called when receiving data from trusted source
	'fromJSON'	# function(key, data, parentObject) - Called when receiving data from untrusted source
	'toDB'		# fx to call when sending to DB

	'asserts'	# list of asserts: [assertKey, assertParam, assertCompare(currentObj, param), errMsg]
	'pipe'		# Pipeline

	'nested'	# subschema when object or list or map

]

# Descriptor formats
descFormats= [
	'ROOT'		# Model root descriptor (used to enable methods on root object)
	'ATTRIBUTE' # Simple attribute
	'OBJECT'
	'LIST'
	'MAP'

	'LINK' # link to an other model descriptor
]

# VARS
SCHEMA= {}
SCHEMA[v]= k for v,k in schemaElement
SCHEMA.length= schemaElement.length

# Link
SCHEMA.linkedTo= SCHEMA.prototype # set the same index as prototype
SCHEMA.model= SCHEMA.ignoreJsonAttrs # set the same index as prototype

# TYPES
SCHEMA[v]= i for v,i in descFormats


SCHEMA_ATTR= {}
SCHEMA_ATTR[v]=k for v,k in schemaAttrs
SCHEMA_ATTR.length= schemaAttrs.length

# Flags
SCHEMA.JSON				=     0b11
SCHEMA.ignoreJsonParse	=     0b10 # Do not change this value
SCHEMA.IS_FREEZE_SET	=    0b100 # is FREEZE value is set (used when inherit from parent)
SCHEMA.FREEZE			=   0b1000
SCHEMA.VIRTUAL			=  0b10000
SCHEMA.NOT_NULL			= 0b100000