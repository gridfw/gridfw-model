

# String
STRING_MAX = 3000 # String max length
HTML_MAX_LENGTH= 10000 # HTML max length

PASSWD_MIN	= 8 # password min length
PASSWD_MAX	= 100 # password max length

URL_MAX_LENGTH= 3000 # URL max length
DATA_URL_MEX_LENGTH = 30000 # Data URL max length

# schema attribute descriptor count
SCHEMA_COUNT = 5 # @see schema/schema.tempate.js for more info

# hex check
HEX_CHECK	= /^[0-9a-f]$/i
# Email check
EMAIL_CHECK = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/


# symbols
SCHEMA = Symbol 'Model schema'
DESCRIPTOR = Symbol 'Descriptor'
TYPE_ATTR = '_type' # extra attr inside object, refers its Model

# methods
_create = Object.create
_setPrototypeOf= Object.setPrototypeOf
_defineProperties= Object.defineProperties
_defineProperty= Object.defineProperty
_has = Reflect.has
_owns= (obj, property)-> Object.hasOwnProperty.call obj, property


# Array
_ArrayPush = Array::push

# remove str element from array
_arrRemoveItem = (arr, ele)->
	len = arr.length
	i=0
	while i < len
		if arr[i] is ele
			arr.splice i, 1
			--len
		else
			++i
	return


# check
_isPlainObject = (obj)-> obj and typeof obj is 'object' and not Array.isArray obj

# clone
_clone = (obj)->
	if typeof obj is 'object' and obj
		if Array.isArray obj
			Array.from obj
		else
			Object.assign {}, obj
	else
		obj

# json pretty
_prettyJSON = (k,v) ->
	if typeof v is 'function'
		v= "[FUNCTION #{v.name}]"
	else if typeof v is 'symbol'
		v= "[SYMBOL #{v}]"
	else if v instanceof Error
		v =
			message: v.message
			stack: v.stack.split("\n")[0..2]
	v
_jsonPretty = (obj)->
	JSON.stringify obj, _prettyJSON, "\t"