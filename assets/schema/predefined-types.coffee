###*
 * Utilities
###
_checkIsNumber
# _Set2Array
# _Map2Obj


###*
 * Predefine types
###
_CHECK_IS_OBJECT= (data)-> typeof data is 'object' and not Array.isArray data
_CHECK_IS_LIST= (data)-> Array.isArray data

Model
###
# Basic types
###
.directive Object, ->
	Model.check _CHECK_IS_OBJECT
	.convert -> throw 'Invalid Object'
.directive Array, ->
	# accept to have the element directly when array contains just one element
	Model.check _CHECK_IS_LIST
	.convert (data)-> if data? then [data] else []
	.assertions
		min:
			param: _checkIsNumber
			assert: (data, min) -> throw "Array length [#{data.length}] is less then #{min}" if data.length < min
		max:
			param: _checkIsNumber
			assert: (data, max) -> throw "Array length [#{data.length}] is greater then #{max}" if data.length > max
		length:
			param: _checkIsNumber
			assert: (data, len) -> throw "Array length [#{data.length}] expected #{len}" if data.length isnt len
.directive 'Mixed', ->
	Model.check: -> true
###
# Boolean
###
.directive Boolean, ->
	Model.check (data) -> typeof data is 'boolean'
	.convert (data) ->
		throw 'Expected boolean, got Object' if typeof data is 'object' and data
		!!data
###
# Number
###
.directive Number, ->
	Model.check (data) -> typeof data is 'number'
	.convert (data) ->
		value = +data
		throw "Invalid number: #{data}" if isNaN value
		value
	.assertions
		min:
			param: _checkIsNumber
			assert: (data, min) -> throw "value less then #{min}" if data < min
		max:
			param: _checkIsNumber
			assert: (data, max) -> throw "value exceeds #{max}" if data > max
.directives
	Int: ->
		Model.Number
		.check (data) -> Number.isSafeInteger data
		.convert (data) ->
			value = +data
			throw "Invalid integer #{data}" unless Number.isSafeInteger value
			value
	Unsigned: ->
		Model.Number
		.check (data) -> Number.isSafeInteger data and data >= 0
		.convert (data) ->
			value = +data
			throw "Invalid positive integer #{data}" unless Number.isSafeInteger value and data >= 0
			value
	Hex: ->
		Model.check (data) -> typeof data is 'string' and HEX_CHECK.test data
		.convert (data) ->
			throw "Invalid Hex: #{data}" unless typeof data is 'number'
			data.toString 16
		.assertions
			min:
				param: _checkIsNumber
				assert: (data, min)-> throw "value less then: #{min}" if Number.parse(data, 16) < min
			max:
				param: _checkIsNumber
				assert:(data, max)-> throw "value greater then: #{max}" if Number.parse(data, 16) > max
###
# Date
###
.directive Date, ->
	Model.check (data) -> data instanceof Date
	.convert (data) ->
		v= new Date data
		throw "Invalid date: #{data}" if v.toString() is 'Invalid Date'
		v
	.assertions
		min: # min date
			param: (value)-> throw 'Expected valid date' unless value instanceof Date
			assert: (data, min)-> throw "Date before: #{min}" if value < min
		max: # max date
			param: (value)-> throw 'Expected valid date' unless value instanceof Date
			assert: (data, max)-> throw "value greater then: #{max}" if Number.parse(max, 16) > max
###
# Map
###
# .directive Map, ->
# 	Model.check (data) -> data instanceof Map
# 	.convert (data) ->
# 		throw "Invalid Map: #{data}" unless typeof data is 'object'
# 		new Map Object.entries data
# 	.toJSON _Map2Obj
# 	.toDB _Map2Obj
# ###
# # WeakMap
# ###
# .directive WeakMap, ->
# 	Model.check (data) -> data instanceof WeakMap
# 	.convert (data) ->
# 		throw "Invalid WeakMap: #{data}" unless typeof data is 'object'
# 		new WeakMap Object.entries data
# 	.toJSON _Map2Obj
# 	.toDB _Map2Obj
# ###
# # Set
# ###
# .directive Set, ->
# 	Model.check (data) -> data instanceof Set
# 	.convert (data) ->
# 		throw "Invalid Set: #{data}" unless Array.isArray data
# 		new Set data
# 	.toJSON _Set2Array
# 	.toDB _Set2Array
# ###
# # WeakSet
# ###
# .directive WeakSet, ->
# 	Model.check (data) -> data instanceof WeakSet
# 	.convert (data) ->
# 		throw "Invalid Set: #{data}" unless Array.isArray data
# 		new WeakSet data
# 	.toJSON _Set2Array
# 	.toDB _Set2Array

###
# Text, String
###
.directive 'Text', ->
	Model.check (data) -> typeof data is 'string'
	.convert (data) ->
		throw 'Expected String, got Object.' if typeof data is 'object'
		data.toString()
	.assert max: STRING_MAX
	.assertions
		min:
			param: _checkIsNumber
			assert: (data, min)-> throw "String length less then #{min}" if data.length < min
		max:
			param: _checkIsNumber
			assert: (data, max)-> throw "String exceeds #{max}" if data.length > max
		length:
			param: _checkIsNumber
			assert: (data, len)-> throw "String length [#{data.length}] expected #{len}" if data.length isnt len
		# match regex
		match:
			param: (value)-> throw 'Expected RegExp' unless value instanceof RegExp
			assert: (data, regex)-> throw "Expected to match: #{regex}" unless regex.test data.href
.directive String, -> # String, HTML escaped
	Model.Text.pipe (data) -> xssEscape data
.directives
	# HTML: remove keep only safe HTML, remove images
	HTML: ->
		Model.Text.assert max: HTML_MAX_LENGTH
		.pipe (data)-> xssClean data, imgs: off
	# HTMLImgs: remove keep only safe HTML and images
	HTMLImgs: ->
		Model.Text.assert max: HTML_MAX_LENGTH
		.pipe (data)-> xssClean data, imgs: on
	# Email
	Email: ->
		Model.Text.check (data) -> typeof data is 'string' and EMAIL_CHECK.test data
		.convert (data) -> throw "Invalid Email: #{data}"
		.assert max: STRING_MAX
	# Password
	Password: ->
		Model.Text.convert (data) -> throw "Invalid Password: #{data}"
		.assert
			min: PASSWD_MIN
			max: PASSWD_MAX
###
# URL
###
.directive URL, ->
	Model.check (data) -> data instanceof URL
	.convert (data) ->
		throw "Illegal URL: #{data}" unless typeof data is 'string'
		new URL data
	.toJSON	: (data) -> data.href
	.toDB	: (data) -> data.href
	.assert max: URL_MAX_LENGTH
	.assertions
		min:
			param: _checkIsNumber
			assert: (data, min)->
				urlLen = data.href.length
				throw "URL length [#{urlLen}] is less then #{min}" if urlLen < min
		max:
			param: _checkIsNumber
			assert: (data, max)->
				urlLen = data.href.length
				throw "URL length [#{urlLen}] is greater then #{max}" if urlLen > max
		length:
			param: _checkIsNumber
			assert: (data, len)->
				urlLen = data.href.length
				throw "URL length [#{urlLen}] expected #{len}" if urlLen isnt len
		match:
			param: (value)-> throw 'Expected RegExp' unless value instanceof RegExp
			assert: (data, regex)-> throw "Expected to match: #{regex}" unless regex.test data.href
.directive 'Image', -> Model.URL.assert max: DATA_URL_MEX_LENGTH
###
# UUID
###
.directives
	ObjectId: ->
		Model.check (data) -> typeof data is 'object' and data._bsontype is 'ObjectID'
		.convert (data) -> ObjectId.createFromHexString data
	# UUID: ->
	# 	Model.check
	# 	.convert 