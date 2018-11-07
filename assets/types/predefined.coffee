###*
 * Predefined types
###
Model
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
###*
 * Integer
###
.type
	name	: 'Int'
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
 * String
 * HTML will be escaped
###
.type
	name	: String
	check	: (data) -> typeof data is 'string'
	convert	: (data) -> data.toString()
	assert	:
		max: STRING_MAX
	pipe	: (data)-> xss.escape data
###*
 * Text
 * String as it is
 * max length is STRING_MAX
###
.type
	name	: 'Text'
	check	: (data) -> typeof data is 'string'
	convert	: (data) -> data.toString()
	assert	:
		max: STRING_MAX
###*
 * URL
###
.type
	name	: URL
	check	: (data, schema) ->
		if data instanceof URL
			throw new Error "URL exceeds #{schema.max} caracters" if data.href.length > schema.max
			return true
		else
			return false
	convert	: (data, schema) ->
		if typeof data is 'string' and data.length > schema.max
			throw new Error "URL exceeds #{schema.max} caracters"
		new URL datadata.href || data
	.assert
		max: URL_MAX_LENGTH
	toJSON	: (data) -> data.href
	toDB	: (data) -> data.href # save to database
###*
 * Image URL
###
.type
	name: 'Image'
	check: (data, schema)->
		if data instanceof URL
			throw new Error "Image URL exceeds #{schema.max} caracters" if data.href.length > schema.max
			return true
		else
			return false
	convert	: (data, schema) ->
		if typeof data is 'string' and data.length > schema.max
			throw new Error "Image URL exceeds #{schema.max} caracters"
		new URL datadata.href || data
	.assert
		max: DATA_URL_MEX_LENGTH
	toJSON	: (data) -> data.href
	toDB	: (data) -> data.href # save to database

###*
 * HTML
 * String, remove images, remove dangerous code
###
.type
	name	: 'HTML'
	check	: (data) -> typeof data is 'string'
	convert	: (data) -> data.toString()
	assert	:
		max: HTML_MAX_LENGTH
	pipe	: (data)-> xss.clean data, imgs: off
###*
 * HTML with images
 * remove dangerouse code
###
.type
	name	: 'HTMLImgs'
	check	: (data) -> typeof data is 'string'
	convert	: (data) -> data.toString()
	assert	:
		max: HTML_MAX_LENGTH
	pipe	: (data)-> xss.clean data, imgs: on
###*
 * Email
###
.type
	name	: 'Email'
	check	: (data) -> typeof data is 'string' and EMAIL_CHECK.test data
	convert	: (data) -> throw new Error "Invalid Email: #{data}"
	assert	: max: STRING_MAX
###*
 * Password
###
.type
	name	: 'Password'
	check	: (data) -> typeof data is 'string'
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
	check	: (data) -> true
