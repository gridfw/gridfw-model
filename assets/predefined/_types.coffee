###*
 * Checkers
###
# _CHECK_IS_OBJECT= (data)-> typeof data is 'object' and not Array.isArray data
_checkIsUnsigned= (value)-> throw new Error "Expected positive integer" unless Number.isSafeInteger(value) and value >= 0
_checkIsNumber= (value)-> throw new Error "Expected number" unless typeof value is 'number'
_checkParamDate= (value)-> throw 'Expected valid date' unless (typeof value is 'number') or (value instanceof Date)

HEX_CHECK	= /^[0-9a-f]+$/i
###*
 * Predefined types
###
Model
# OBJECT
.addType 'Object', Model.check (data)-> typeof data is 'object' and data and not Array.isArray data
# LIST
.addType [Array, 'Array', 'List'],
	Model.check (data)-> Array.isArray data
	.convert (data)-> if data? then [data] else []
	.asserts
		lt:
			param: _checkIsUnsigned
			msg: 'Array length expected less than #{param}'
			assert: (obj, param)-> obj.length < param
		lte:
			param: _checkIsUnsigned
			msg: 'Array length expected less than or equals to #{param}'
			assert: (obj, param)-> obj.length <= param
		gt:
			param: _checkIsUnsigned
			msg: 'Array length expected greater than #{param}'
			assert: (obj, param)-> obj.length > param
		gte:
			param: _checkIsUnsigned
			msg: 'Array length expected greater than or equals to #{param}'
			assert: (obj, param)-> obj.length >= param
		length:
			param: _checkIsUnsigned
			msg: 'Array length expected #{param}'
			assert: (obj, param)-> obj.length is param
# MAP
_getMapLen= (obj)-> if obj instanceof Map then obj.size else _keys(obj).length
Model.addType [Map, 'Map'],
	Model.check (data)-> typeof data is 'object' and data and not Array.isArray data
	.asserts
		lt:
			param: _checkIsUnsigned
			msg: 'Map length expected less than #{param}'
			assert: (obj, param)-> _getMapLen(obj) < param
		lte:
			param: _checkIsUnsigned
			msg: 'Map length expected less than or equals to #{param}'
			assert: (obj, param)-> _getMapLen(obj) <= param
		gt:
			param: _checkIsUnsigned
			msg: 'Map length expected greater than #{param}'
			assert: (obj, param)-> _getMapLen(obj) > param
		gte:
			param: _checkIsUnsigned
			msg: 'Map length expected greater than or equals to #{param}'
			assert: (obj, param)-> _getMapLen(obj) >= param
		length:
			param: _checkIsUnsigned
			msg: 'Map length expected #{param}'
			assert: (obj, param)-> _getMapLen(obj) is param
# Boolean
Model.addType [Boolean, 'Boolean'],
	Model.check (data) -> typeof data is 'boolean'
	.convert (data) ->
		throw 'Expected Boolean, got Object' if typeof data is 'object' and data
		!!data 
#Number
.addType [Number, 'Number'],
	Model.check (data) -> typeof data is 'number'
	.convert (data) ->
		value = +data
		throw "Invalid number: #{data}" if isNaN value
		value
	.asserts 
		asserts:
			lt:
				param: _checkIsNumber
				msg: 'Expected less than #{param}'
				assert: (obj, param)-> obj < param
			lte:
				param: _checkIsNumber
				msg: 'Expected less than or equals to #{param}'
				assert: (obj, param)-> obj <= param
			gt:
				param: _checkIsNumber
				msg: 'Expected greater than #{param}'
				assert: (obj, param)-> obj > param
			gte:
				param: _checkIsNumber
				msg: 'Expected greater than or equals to #{param}'
				assert: (obj, param)-> obj >= param
.addType 'Int',
	Model.Number.check (data) -> Number.isSafeInteger data
	.convert (data, check)->
		value = +data
		throw "Invalid integer #{data}" unless check value
		value
.addType 'Unsigned', Model.Int.gte(0)
# HEX
.addType 'Hex',
	Model.check (data)-> typeof data is 'string' and HEX_CHECK.test data
	.convert (data)->
		throw "Invalid Hex: #{data}" unless typeof data is 'number'
		data.toString 16
# BIG int
.addType ['BigInt', BigInt],
	Model.check (data)-> typeof data is 'bigint'
	.convert (data)-> BigInt(data)
# DATE
.addType [Date, 'Date'],
	Model.check (data) -> data instanceof Date
	.convert (data)->
		v= new Date data
		throw "Invalid date: #{data}" if v.toString() is 'Invalid Date'
		v
	.asserts
		lt:
			param: _checkParamDate
			msg: 'Expected less than #{param}'
			assert: (obj, param)-> obj < param
		lte:
			param: _checkParamDate
			msg: 'Expected less than or equals to #{param}'
			assert: (obj, param)-> obj <= param
		gt:
			param: _checkParamDate
			msg: 'Expected greater than #{param}'
			assert: (obj, param)-> obj > param
		gte:
			param: _checkParamDate
			msg: 'Expected greater than or equals to #{param}'
			assert: (obj, param)-> obj >= param
# TEXT
.addType [String, 'String'], # Native string, no changes
	Model.check (data) -> typeof data is 'string'
	.convert (data) ->
		throw 'Expected String, got Object.' if typeof data is 'object'
		data.toString()
	.asserts
		lt:
			param: _checkIsUnsigned
			msg: 'String length expected less than #{param}'
			assert: (obj, param)-> obj.length < param
		lte:
			param: _checkIsUnsigned
			msg: 'String length expected less than or equals to #{param}'
			assert: (obj, param)-> obj.length <= param
		gt:
			param: _checkIsUnsigned
			msg: 'String length expected greater than #{param}'
			assert: (obj, param)-> obj.length > param
		gte:
			param: _checkIsUnsigned
			msg: 'String length expected greater than or equals to #{param}'
			assert: (obj, param)-> obj.length >= param
		length:
			param: _checkIsUnsigned
			msg: 'String length expected #{param}'
			assert: (obj, param)-> obj.length is param
		match:
			param: (value)-> throw 'Expected RegExp' unless value instanceof RegExp
			assert: (data, regex)-> throw "Expected to match: #{regex}" unless regex.test data
	.lte STRING_MAX_LENGTH
.addType 'Text', Model.String.pipeOnce Model.xssEscape # Encode HTML caracters
.addType 'HTML', Model.String.lte(HTML_MAX_LENGTH).pipeOnce Model.xssNoImages
.addType 'HTMLImgs', Model.String.lte(HTML_MAX_LENGTH).pipeOnce Model.xss
# Email & Password
.addType 'Email', Model.String.match EMAIL_CHECK
.addType 'Password', Model.String.gte(PASSWD_MIN)

# URL
.addType [URL, 'URL'],
	Model.check (data)-> data instanceof URL
	.convert (data)-> new URL data
	.toJSON (data) -> data.href
	.toDB (data) -> data.href
	.asserts
		lt:
			param: _checkIsUnsigned
			msg: 'URL length expected less than #{param}'
			assert: (obj, param)-> obj.href.length < param
		lte:
			param: _checkIsUnsigned
			msg: 'URL length expected less than or equals to #{param}'
			assert: (obj, param)-> obj.href.length <= param
		gt:
			param: _checkIsUnsigned
			msg: 'URL length expected greater than #{param}'
			assert: (obj, param)-> obj.href.length > param
		gte:
			param: _checkIsUnsigned
			msg: 'URL length expected greater than or equals to #{param}'
			assert: (obj, param)-> obj.href.length >= param
		length:
			param: _checkIsUnsigned
			msg: 'URL length expected #{param}'
			assert: (obj, param)-> obj.href.length is param
		match:
			param: (value)-> throw 'Expected RegExp' unless value instanceof RegExp
			assert: (data, regex)-> throw "Expected to match: #{regex}" unless regex.test data.href
		pathMatches:
			param: (value)-> throw 'Expected RegExp' unless value instanceof RegExp
			assert: (data, regex)-> throw "URL path expected to match: #{regex}" unless regex.test data.pathname
	.lte URL_MAX_LENGTH
.addType 'ImageURL', Model.URL.lte DATA_URL_MEX_LENGTH
.addType 'FileURL', Model.URL.lte DATA_URL_MEX_LENGTH

# ObjectId
.addType 'ObjectId',
	Model.check (data)-> data?._bsontype is 'ObjectID'
	.convert (data)-> ObjectId.createFromHexString data