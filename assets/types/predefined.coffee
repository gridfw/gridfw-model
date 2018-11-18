###*
 * Predefined types
###
Model
###*
 * Basic
###
.type
	name: 'Object'
	check: (data)-> typeof data is 'object'
	convert: -> throw new Error 'Invalid Object'
.type
	name: 'Array'
	check: (data)-> Array.isArray data
	convert: -> throw new Error 'Invalid Array'
	assertions:
		min:
			check: _checkIsNumber
			assert: (data, min) -> throw new Error "Array length [#{data.length}] is less then #{min}" if data.length < min
		max:
			check: _checkIsNumber
			assert: (data, max) -> throw new Error "Array length [#{data.length}] is greater then #{max}" if data.length > max
		length:
			check: _checkIsNumber
			assert: (data, len) -> throw new Error "Array length [#{data.length}] expected #{len}" if data.length isnt len
###*
 * Boolean
###
.type
	name	: Boolean
	check	: (data) -> typeof data is 'boolean'
	convert	: (data) -> !!data
###*
 * Number
###
.type
	name	: Number
	check	: (data) -> typeof data is 'number'
	convert	: (data) ->
		value = +data
		throw new Error "Invalid number #{data}" if isNaN value
		value
	# define assertion for this type
	assertions:
		min:
			check: _checkIsNumber
			assert: (data, min) -> throw new Error "value less then #{min}" if data < min
		max:
			check: _checkIsNumber
			assert: (data, max) -> throw new Error "value exceeds #{max}" if data > max
###*
 * Integer
###
.type
	name	: 'Int'
	extends	: Number
	check	: (data) -> Number.isSafeInteger data
	convert	: (data) ->
		value = +data
		throw new Error "Invalid integer #{data}" unless Number.isSafeInteger value
		value
###*
 * Positive integer
###
.type
	name	: 'Unsigned'
	extends	: Number
	check	: (data) -> Number.isSafeInteger data and data >= 0
	convert	: (data) ->
		value = +data
		throw new Error "Invalid positive integer #{data}" unless Number.isSafeInteger value and data >= 0
		value
###*
 * Hexadicimal number (as string)
 * will be converted when number
###
.type
	name	: 'Hex'
	check	: (data) -> typeof data is 'string' and HEX_CHECK.test data
	convert	: (data) ->
		throw new Error "Invalid Hex: #{data}" unless typeof data is 'number'
		data.toString 16
	assertions:
		min:
			check: _checkIsNumber
			assert: (data, min)-> throw new Error "value less then #{min}" if Number.parse(data, 16) < min
		max:
			check: _checkIsNumber
			assert:(data, max)-> throw new Error "value greater then #{max}" if Number.parse(data, 16) > max

###*
 * Date
###
.type
	name	: Date
	check	: (data) -> data instanceof Date
	convert	: (data) ->
		v= new Date data
		throw new Error "Invalid date: #{data}" if v.toString() is 'Invalid Date'
		v
	assertions:
		min: # min date
			check: (value)-> throw new Error 'Expected valid date' unless value instanceof Date
			assert: (data, min)-> throw new Error "Date before #{min}" if value < min
		max: # max date
			check: (value)-> throw new Error 'Expected valid date' unless value instanceof Date
			assert: (data, max)-> throw new Error "value greater then #{max}" if Number.parse(max, 16) > max
###*
 * Buffer
###
.type
	name	: Buffer
	check	: (data) -> data instanceof Buffer
	convert	: (data) -> new Buffer data
###*
 * Map
###
.type
	name	: Map
	check	: (data) -> data instanceof Map
	convert	: (data) ->
		throw new Error "Invalid Map: #{data}" unless typeof data is 'object'
		new Map Object.entries data
	toJSON	: _Map2Obj
	toDB	: _Map2Obj

###*
 * Set
###
.type
	name	: set
	check	: (data) -> data instanceof Set
	convert	: (data) ->
		throw new Error "Invalid Set: #{data}" unless Array.isArray data
		new Set data
	toJSON	: _Set2Array
	toDB	: _Set2Array
###*
 * WeakMap
###
.type
	name	: WeakMap
	check	: (data) -> data instanceof WeakMap
	convert	: (data) ->
		throw new Error "Invalid WeakMap: #{data}" unless typeof data is 'object'
		new WeakMap Object.entries data
	toJSON	: _Map2Obj
	toDB	: _Map2Obj
###*
 * WeakSet
###
.type
	name	: WeakSet
	check	: (data) -> data instanceof WeakSet
	convert	: (data) ->
		throw new Error "Invalid WeakSet: #{data}" unless Array.isArray data
		new WeakSet data
	toJSON	: _Set2Array
	toDB	: _Set2Array
###*
 * Text
 * String as it is
 * max length is STRING_MAX
###
.type
	name	: 'Text'
	check	: (data) -> typeof data is 'string'
	convert	: (data) -> data.toString()
	assertions:
		min:
			check: _checkIsNumber
			assert: (data, min)-> throw new Error "String length less then #{min}" if data.length < min
		max:
			check: _checkIsNumber
			assert: (data, max)-> throw new Error "String exceeds #{max}" if data.length > max
		length:
			check _checkIsNumber
			assert: (data, len)-> throw new Error "String length [#{data.length}] expected #{len}" if data.length isnt len
		# match regex
		match:
			check: (value)-> throw new Error 'Expected RegExp' unless value instanceof RegExp
			assert: (data, regex)-> throw new Error "Expected to match: #{regex}" unless regex.test data.href
	assert	:
		max: STRING_MAX
###*
 * String
 * HTML will be escaped
###
.type
	name	: String
	extends : 'Text'
	pipe	: (data)-> xss.escape data
###*
 * URL
###
.type
	name	: URL
	check	: (data) -> data instanceof URL
	convert	: (data) -> new URL datadata.href || data
	assertions:
		min:
			check: _checkIsNumber
			assert: (data, min)->
				urlLen = data.href.length
				throw new Error "URL length [#{urlLen}] is less then #{min}" if urlLen < min
		max:
			check: _checkIsNumber
			assert: (data, max)->
				urlLen = data.href.length
				throw new Error "URL length [#{urlLen}] is greater then #{max}" if urlLen > max
		length:
			check: _checkIsNumber
			assert: (data, len)->
				urlLen = data.href.length
				throw new Error "URL length [#{urlLen}] expected #{len}" if urlLen isnt len
		match:
			check: (value)-> throw new Error 'Expected RegExp' unless value instanceof RegExp
			assert: (data, regex)-> throw new Error "Expected to match: #{regex}" unless regex.test data.href
	assert	:
		max: URL_MAX_LENGTH
	toJSON	: (data) -> data.href
	toDB	: (data) -> data.href # save to database
###*
 * Image URL
###
.type
	name: 'Image'
	extends: URL
	assert
		max: DATA_URL_MEX_LENGTH
###*
 * HTML
 * String, remove images, remove dangerous code
###
.type
	name	: 'HTML'
	extends	: 'Text'
	assert	:
		max: HTML_MAX_LENGTH
	pipe	: (data)-> xss.clean data, imgs: off
###*
 * HTML with images
 * remove dangerouse code
###
.type
	name	: 'HTMLImgs'
	extends	: 'Text'
	assert	:
		max: HTML_MAX_LENGTH
	pipe	: (data)-> xss.clean data, imgs: on
###*
 * Email
###
.type
	name	: 'Email'
	extends	: 'Text'
	check	: (data) -> typeof data is 'string' and EMAIL_CHECK.test data
	convert	: (data) -> throw new Error "Invalid Email: #{data}"
	assert	:
		max: STRING_MAX
###*
 * Password
###
.type
	name	: 'Password'
	extends	: 'Text'
	convert	: (data) -> throw new Error "Invalid Password: #{data}"
	assert	:
		min: PASSWD_MIN
		max: PASSWD_MAX
###*
 * Mongo ObjectId
###
.type
	name	: 'ObjectId'
	check	: (data) -> typeof data is 'object' and data._bsontype is 'ObjectID'
	convert	: (data) -> ObjectId.createFromHexString data #TODO make this logic
###*
 * UUID
###
.type
	name	: 'UUID'
	check	: (data) -> 
	convert	: (data) ->
###*
 * Mixed
###
.type
	name	: Mixed
	check	: -> true
