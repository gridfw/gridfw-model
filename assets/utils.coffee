
# Object shortcuts
_create = Object.create
_setPrototypeOf= Object.setPrototypeOf
_getPrototypeOf= Object.getPrototypeOf
_defineProperties= Object.defineProperties
_defineProperty= Object.defineProperty
_has = Reflect.has
_owns= (obj, property)-> Object.hasOwnProperty.call obj, property
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
# arr difference
_arrDiff = (arr, diff)->
	result = []
	for el in arr
		result.push el unless el in diff
	return result

### get schema attributes ###
_getSchemaAttributes= (schema)->
	len = schema.length
	i = <%= SCHEMA.sub %>
	result = []
	while i < len
		result.push schema[i]
		i+= <%= SCHEMA.attrPropertyCount %>
	result
### JSON ###
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