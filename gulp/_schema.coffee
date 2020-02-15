###*
 * Schema template
###
schema=
	# TYPE
	Object: 0
	List: 1

# Object & List descriptor
schemaElement= [
	'type' # schema type: schema.Object or schema.List
	'prototype' # Element prototype
	# 'extensible' # Do Object is extensible
	'ignoreJsonAttrs' # attributes to ignore when serializing as JSON
	'virtuals'	# Virtual attributes

	'toJSON'	# [attrName, toJsonCb, ...] to call when serialising as JSON
	'fromJSON'	# [attrName, toJsonCb, ...] to call when deserializing from JSON
	'toDB'		# [attrName, toJsonCb, ...] to call when sending to DB (could be async)
	'fromDB'	# [attrName, toJsonCb, ...] to call when loading from DB (could be async)
]

# Attributes descriptor
schemaAttrs= [
	'name'	# attr name
	'type'	# Ref to attr type
	'check'	# Check function
	'convert' # convert function

	'null'	# Do value could be null
	'required'	# if the attribute is required
	'freeze'	# If the subobject is freezed (could not accept other attributes)
	'virtual'	# debug purpose, if this attr is virtual (do not save to DB)

	'default'	# debug purpose
	'getOnce'	# debug purpose
	'getter'	# debug purpose
	'setter'	# debug purpose
	'method'	# debug purpose

	'json'		# Debug purpose
	'ignoreJsonParse'	# Debug purpose, when true, ignore when parsing json

	'asserts'	# list of asserts
	'pipe'		# Pipeline

	'nested'	# subschema when object or list or map

]

# VARS
SCHEMA= {}
SCHEMA[v]= k for v,k in schemaElement
SCHEMA_ATTR= {}
SCHEMA_ATTR[v]=k for v,k in schemaAttrs