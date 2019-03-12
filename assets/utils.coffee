
# Object shortcuts
# _create = Object.create
_setPrototypeOf= Object.setPrototypeOf
_getPrototypeOf= Object.getPrototypeOf
_defineProperties= Object.defineProperties
_defineProperty= Object.defineProperty
_getOwnPropertyDescriptors= Object.getOwnPropertyDescriptors
_getOwnPropertyDescriptor= Object.getOwnPropertyDescriptor
_has = Reflect.has
_keys= Object.keys
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



# object manipulation
# clone fields only
_cloneFields= (obj)->
	result= _create null
	for k of obj
		v= _getOwnPropertyDescriptor obj, k
		if 'value' of v
			result[k]= v.value
	result

# ignore fields
_ignoreFields= (obj, ignoreFields, mapFields)->
	attrs= _keys obj
	# check if has some field to ignore
	if ignoreFields and attrs.some (f)-> f in ignoreFields
		result= _create null
		for f in attrs
			unless f in ignoreFields
				fv= _getOwnPropertyDescriptor obj, f
				continue unless 'value' of fv # accept only fields, no getter, setter
				result[f]= fv.value
		attrs= _keys result
	# map fields
	if mapFields and attrs.some (f)-> f of mapFields
		result ?= _cloneFields obj
		# map
		for k,v of mapFields
			if k of result
				result[k]= v result[k], k, obj
	# return
	result || obj

# accept only fields
_onlyFields= (obj, whiteList, mapFields)->
	attrs= _keys obj
	# check if some attr isnt in white list
	if whiteList and attrs.some (f)-> f not in whiteList
		result= _create null
		for f in attrs
			if f in whiteList
				fv= _getOwnPropertyDescriptor obj, f
				if 'value' of fv
					result[f]= fv.value
		attrs= _keys result
	# map fields
	if mapFields and attrs.some (f)-> f of mapFields
		result ?= _cloneFields obj
		# map
		for k,v of mapFields
			if k of result
				result[k]= v result[k], k, obj
	# return
	result || obj