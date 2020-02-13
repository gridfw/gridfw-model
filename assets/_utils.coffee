###*
 * Utils
###
_create= Object.create
_defineProperty= Object.defineProperty
_defineProperties= Object.defineProperties
_keys= Object.keys

_has= Reflect.has

# Array
_isArray= Array.isArray
_arrRemove= (arr, value, nbrRemove)->
	i= 0
	len= arr.length
	nbrRemove?= 1
	while i<len
		if el is value
			arr.splice i, nbrRemove
		else
			++i
	return