###*
 * Utils
###
_create= Object.create
_defineProperty= Object.defineProperty
_defineProperties= Object.defineProperties
_keys= Object.keys
_assign= Object.assign
_setPrototypeOf= Object.setPrototypeOf
_getOwnPropertyDescriptors= Object.getOwnPropertyDescriptors

_has= Reflect.has

# Array
_isArray= Array.isArray
_isStringArray= (arr)-> _isArray(arr) and arr.every (el)-> typeof el is 'string'

###* Remove element inside Array ###
_arrRemove= (arr, value, nbrRemove)->
	i= 0
	len= arr.length
	nbrRemove?= 1
	while i<len
		if arr[i] is value
			arr.splice i, nbrRemove
		else
			++i
	return


