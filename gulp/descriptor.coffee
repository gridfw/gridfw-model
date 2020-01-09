###*
 * Schema descriptor
###
# Common Object & List descriptor
schemaDescriptor= [
	'schemaType'	# schema.Object or schema.List
	'prototype'		# Object prototype
	'extensible'	# Object coud contains none listed properties

	'jsonIgnoreAttributes'	# list of attributes to ignore when serializing JSON
	'toJSON'		# function to call when serializing to JSON
	'fromJSON'		# function to call when parsing from JSON
	
	'virtual'		# list of attributes to ignore when sending to DB
	'toDB'			# function to call when sending to DB
	'fromDB'		# function to call when receiving from DB
]

# Object attributes & list elements descriptor
attrSchema= [
	'name'	# Name of the attribute when Object
	# Type descriptor
	'type'	# pointer to type
	'check'	# checker
	'convert' # converter
	# descriptors
	'null'	# if could be null or undefined
	'required' # if this attribute is required
	'ignoreJsonParse' # Ignore when JSON parsing

	'asserts' # list of assert functions
	'pipe'	# pipe functions
]