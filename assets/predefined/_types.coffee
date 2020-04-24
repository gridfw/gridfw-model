###*
 * Predefined types
###
_checkIsUnsigned= (value)-> throw new Error "Expected positive integer" unless Number.isSafeInteger(value) and value >= 0
_checkIsNumber= (value)-> throw new Error "Expected number" unless typeof value is 'number'
_checkParamDate= (value)-> throw 'Expected valid date' unless (typeof value is 'number') or (value instanceof Date)

HEX_CHECK	= /^[0-9a-f]+$/i


ModelClass
# MIXED
.addType 'Mixed',
	Mixed().check(-> true).convert (data)-> data
# OBJECT
.addType 'Object',
	Mixed()
		.check (data)-> typeof data is 'object' and data and not _isArray data
		.convert (data)->
			throw 'Expected Object' unless typeof data is 'object' and data and not _isArray data
			return data
# LIST
.addType [Array, 'Array', 'List'],
	Mixed()
	.check (data)-> _isArray data
	.convert (data)->
		unless _isArray data
			data= if data? then [data] else []
		return data
	.asserts
		lt:
			param: _checkIsUnsigned
			msg: '#{path} Array length expected less than #{param}'
			assert: (obj, param)-> obj.length < param
		lte:
			param: _checkIsUnsigned
			msg: '#{path} Array length expected less than or equals to #{param}'
			assert: (obj, param)-> obj.length <= param
		gt:
			param: _checkIsUnsigned
			msg: '#{path} Array length expected greater than #{param}'
			assert: (obj, param)-> obj.length > param
		gte:
			param: _checkIsUnsigned
			msg: '#{path} Array length expected greater than or equals to #{param}'
			assert: (obj, param)-> obj.length >= param
		length:
			param: _checkIsUnsigned
			msg: '#{path} Array length expected #{param}'
			assert: (obj, param)-> obj.length is param
# MAP
.addType [Map, 'Map'], do ->
	_getMapLen= (obj)-> if obj instanceof Map then obj.size else _keys(obj).length
	return Mixed()
	.check (data)-> typeof data is 'object' and data and not _isArray data
	.convert (data)->
		throw 'Expected Object or Map' unless typeof data is 'object' and data and not _isArray data
		return data
	.asserts
		lt:
			param: _checkIsUnsigned
			msg: '#{path} Map length expected less than #{param}'
			assert: (obj, param)-> _getMapLen(obj) < param
		lte:
			param: _checkIsUnsigned
			msg: '#{path} Map length expected less than or equals to #{param}'
			assert: (obj, param)-> _getMapLen(obj) <= param
		gt:
			param: _checkIsUnsigned
			msg: '#{path} Map length expected greater than #{param}'
			assert: (obj, param)-> _getMapLen(obj) > param
		gte:
			param: _checkIsUnsigned
			msg: '#{path} Map length expected greater than or equals to #{param}'
			assert: (obj, param)-> _getMapLen(obj) >= param
		length:
			param: _checkIsUnsigned
			msg: '#{path} Map length expected #{param}'
			assert: (obj, param)-> _getMapLen(obj) is param
# Boolean
.addType [Boolean, 'Boolean'],
	Mixed()
	.check (data) -> typeof data is 'boolean'
	.convert (data) ->
		throw 'Expected Boolean, got Object' if typeof data is 'object' and data
		!!data
#Number
.addType [Number, 'Number'],
	Mixed()
	.check (data) -> typeof data is 'number'
	.convert (data) ->
		value = +data
		throw "Invalid number: #{data}" if isNaN value
		value
	.asserts
		lt:
			param: _checkIsNumber
			msg: '#{path} Expected less than #{param}'
			assert: (obj, param)-> obj < param
		lte:
			param: _checkIsNumber
			msg: '#{path} Expected less than or equals to #{param}'
			assert: (obj, param)-> obj <= param
		gt:
			param: _checkIsNumber
			msg: '#{path} Expected greater than #{param}'
			assert: (obj, param)-> obj > param
		gte:
			param: _checkIsNumber
			msg: '#{path} Expected greater than or equals to #{param}'
			assert: (obj, param)-> obj >= param
.addType 'Int',
	Mixed().Number.check (data) -> Number.isSafeInteger data
	.convert (data)->
		value = +data
		throw "Invalid integer #{data}" unless Number.isSafeInteger value
		value
.addType 'Unsigned', Mixed().Int.min(0)
# BIG int
.addType ['BigInt', BigInt],
	Mixed()
	.check (data)-> typeof data is 'bigint'
	.convert (data)->
		data= BigInt(data) unless typeof data is 'bigint'
		return data
# DATE
.addType [Date, 'Date'],
	Mixed().check (data) -> data instanceof Date
	.convert (data)->
		unless data instanceof Date
			data= new Date data
			throw "Invalid date" if data.toString() is 'Invalid Date'
		return data
	.asserts
		lt:
			param: _checkParamDate
			msg: '#{path} Expected less than #{param}'
			assert: (obj, param)-> obj < param
		lte:
			param: _checkParamDate
			msg: '#{path} Expected less than or equals to #{param}'
			assert: (obj, param)-> obj <= param
		gt:
			param: _checkParamDate
			msg: '#{path} Expected greater than #{param}'
			assert: (obj, param)-> obj > param
		gte:
			param: _checkParamDate
			msg: '#{path} Expected greater than or equals to #{param}'
			assert: (obj, param)-> obj >= param
# TEXT
.addType [String, 'String'], # Native string, no changes
	Mixed()
	.check (data) -> typeof data is 'string'
	.convert (data) ->
		unless typeof data is 'string'
			throw 'Expected String, got Object.' if typeof data is 'object'
			data= data.toString()
		return data
	.asserts
		lt:
			param: _checkIsUnsigned
			msg: '#{path} String length expected less than #{param}'
			assert: (obj, param)-> obj.length < param
		lte:
			param: _checkIsUnsigned
			msg: '#{path} String length expected less than or equals to #{param}'
			assert: (obj, param)-> obj.length <= param
		gt:
			param: _checkIsUnsigned
			msg: '#{path} String length expected greater than #{param}'
			assert: (obj, param)-> obj.length > param
		gte:
			param: _checkIsUnsigned
			msg: '#{path} String length expected greater than or equals to #{param}'
			assert: (obj, param)-> obj.length >= param
		length:
			param: _checkIsUnsigned
			msg: '#{path} String length expected #{param}'
			assert: (obj, param)-> obj.length is param
		match:
			param: (value)-> throw 'Expected RegExp' unless value instanceof RegExp
			msg: '#{path} Expected to match: #{param}'
			assert: (data, regex)-> regex.test data
	.lte STRING_MAX_LENGTH
.addType 'Text', Mixed().String.pipeOnce ModelClass.escape # Encode HTML caracters
.addType 'HTML', Mixed().String.lte(HTML_MAX_LENGTH).pipeOnce ModelClass.xssNoImages
.addType 'HTMLImgs', Mixed().String.lte(HTML_MAX_LENGTH).pipeOnce ModelClass.cleanHTML
# Email & Password
.addType 'Email', Mixed().String.match EMAIL_CHECK
.addType 'Password', Mixed().String.min(PASSWD_MIN).max(PASSWD_MAX)

# HEX
.addType 'Hex',
	Mixed().String
	.check (data)-> typeof data is 'string' and HEX_CHECK.test data
	.convert (data)->
		unless typeof data is 'string' and HEX_CHECK.test data
			throw "Invalid Hex: #{data}" unless typeof data is 'number'
			data= data.toString 16
		return data
# URL
.addType [URL, 'URL'],
	Mixed()
	.check (data)-> data instanceof URL
	.convert (data)->
		data= new URL data unless data instanceof URL
		return data
	.toJSON (data) -> data.href
	.toDB (data) -> data.href
	.asserts
		lt:
			param: _checkIsUnsigned
			msg: '#{path} URL length expected less than #{param}'
			assert: (obj, param)-> obj.href.length < param
		lte:
			param: _checkIsUnsigned
			msg: '#{path} URL length expected less than or equals to #{param}'
			assert: (obj, param)-> obj.href.length <= param
		gt:
			param: _checkIsUnsigned
			msg: '#{path} URL length expected greater than #{param}'
			assert: (obj, param)-> obj.href.length > param
		gte:
			param: _checkIsUnsigned
			msg: '#{path} URL length expected greater than or equals to #{param}'
			assert: (obj, param)-> obj.href.length >= param
		length:
			param: _checkIsUnsigned
			msg: '#{path} URL length expected #{param}'
			assert: (obj, param)-> obj.href.length is param
		match:
			param: (value)-> throw 'Expected RegExp' unless value instanceof RegExp
			msg: '#{path} Expected to match: #{param}'
			assert: (data, regex)-> regex.test data.href
		pathMatches:
			param: (value)-> throw 'Expected RegExp' unless value instanceof RegExp
			msg: '#{path} URL path expected to match: #{param}'
			assert: (data, regex)-> regex.test data.pathname
	.lte URL_MAX_LENGTH
.addType 'ImageURL', Mixed().URL.lte DATA_URL_MEX_LENGTH
.addType 'DataURL', Mixed().URL.lte DATA_URL_MEX_LENGTH

# # ObjectId
# .addType 'ObjectId',
# 	Mixed()
# 	.check (data)-> data?._bsontype is 'ObjectID'
# 	.convert (data)->
# 		throw 'Expected data' unless data
# 		unless data._bsontype is 'ObjectID'
# 			data= ObjectId.createFromHexString data
# 		return data



###******************************************************
	DEFAULT VALUES
*********************************************************###
###*
 * Date.now
###
.addType [Date.now, 'now'], Mixed().Unsigned.default Date.now

###*
 * Random
###
.addType [Math.random, 'random'], Mixed().Number.default Math.random
