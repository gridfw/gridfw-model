###*
 * convert Map to Object
###
_Map2Obj = (data)->
	value = Object.create null
	for k,v if data
		if typeof k is 'number'
			value[k] = v
		else if typeof k is 'string'
			throw new Error 'Could not serialize property "__proto__"' if k is '__proto__'
			value[k] = v
		else throw new Error 'Could not serialize Map'
	return value
###*
 * convert Set to Array
###
_Set2Array = (data) -> Array.from data
