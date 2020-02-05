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
	'extensible' # Do Object is extensible
	'ignoreJsonAttrs' # attributes to ignore when serializing as JSON
	'virtual'	# Virtual attributes

	'toJSON'	# Fx to call when serialising as JSON
	'fromJSON'	# Fx to call when deserializing from JSON
	'toDB'		# Fx to call when sending to DB (could be async)
	'fromDB'	# Fx to call when loading from DB (could be async)
]

# Attributes descriptor
schemaAttrs= [
	'name'	# attr name
	'type'	# Ref to attr type
	'check'	# Check function
	'convert' # convert function

	'null'	# Do value could be null
	'required'	# if the attribute is required
	'ignoreJsonParse'	# when true, ignore when parsing json

	'asserts'	# list of asserts
	'propertyAssert' #  predefined asserts: ['assertName', assertValue, assertFx, ...] exple: ['min', 4, minFx, 'max', 521, maxFx]
	'pipe'	# Pipeline
	'schema'	# subschema when object or list

]