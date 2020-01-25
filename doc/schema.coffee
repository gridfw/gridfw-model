###*
 * Create new Model
###
model= Model.from
	name: ModelName
	schema: ModelSchema
model= Model.name('ModelName').value(ModelSchema)
model= Model.name 'ModelName', ModelSchema

model= Model.overrid 'modelName', ModelSchema
model2= Model.extends 'modelName', 'parentModel', ModelSchema

###*
 * Methods
###
ObjectId= Model.parseObjectId('hexObjectId')
cleanHTML= Model.cleanHTML('htmlText')
cleanHTMLWithImages= Model.cleanHTMLKeepImages('htmlText')
cleanHTML= Model.cleanHTML('htmlText', {options})


###*
 * Directives
###
Model.value({obj})
Model.list({descriptor})= [{descriptor}]
Model.prototype({prototype})	# useful for lists
# MAP
Model.map key, valueSchema
Model.map Model.String.lt(10), Model.Boolean
Model.map
	key: Model.String
	key: (key)->
	value: ModelSchema
	value: (value)->
# Assertions
Model.assert (value)->	# assert function
Model.assert async (value)->	# assert async function
Model.assert 'staticValue'
Model.assert /regex/ [,errMsg]	# assert string to regex
Model.match /regex/ [,errMsg]	# assert string to regex

# Number, String, Arry, Map & Date
lt(value [, msg])	# Less then a value, when string or array, the length
lte(value [, msg])	# Less then or equals a value, length when array or string
gt(value [, msg])	# Greater than a value (value or length)
gte(value [, msg])	# Greater than or equals (value or length)
between(a, b[, msg]) # equals to Model.gte(a[, msg]).lte(b[, msg])

assert
	lt: 415	
	lte: 122
	gt: 2333
	gte: 34322
	length: 1425	# when string or array or map, length must equals this
	match: /regex/i	# match string

# Object States
extensible	# the object could contains unregistred keys
freeze		# The object couldn't contain unregisted keys
extensibleAll	# The object and subobjects
freezeAll	# The object and subobjects
# Attribute states
required	# required attribute
optional	# @default, optional attribute
# Pipe
pipe(fx)	# Call this function as pipeline (after all asserts are executed)
# Default value
attr: Model.default('staticValue')
attr: Model.default(-> Getter)
attr: Model.default(Date.now)
attr: 'staticValue'	# == Model.String.default('staticValue')
attr: true	# == Model.Boolean.default(true)
attr: 34	# == Model.Number.default(34)
attr: Date.now	# == Model.Date.default(Date.now)
# Getter/Setter
attr: Model.get -> Getter
attr: Model.set -> Setter
attr: Model.getOnce -> Getter	# The difference with Model.default(-> Getter), not called when attr is missing
attr: Model.alias('_attr') # equals to: Model.get(->@_attr).set(value-> @_attr=value)
# Create Type
Model.type 'typeName',
	assert: (value)-> checkFx
	convert: (value)-> convert_when_assert_fails
###*
 * Types
###
Mixed	# @default
# String
String	# Native string
Model.Text	# Skip HTML
Model.HTML	# Remove XSS and Images
Model.XML
Model.HTMLImgs
Model.Email
Model.password= String

# Boolean
Boolean
# Number
Number
BigInt
Model.Int32= Model.Int
Model.Int16
Model.Int8= Model.Byte
Model.Unsigned
Model.UnsignedInt= Model.UnsignedInt32
Model.UnsignedInt16
Model.UnsignedInt8= Model.UnsignedByte
Model.Float
Model.Double= Model.Number
Model.Hex	# Number as String hex
Model.Number.base(2|8|10|16|32|64) # use this base when converting from string
# Date
Date
Model.Time	# Timestamp
Model.dateString	# check it's date, but keep/convert it to String
# Buffer
Buffer
ObjectId
UUID

###*
 * Database
###
Model.transient= Model.virtual	# Do not save to DB
Model.persist	# save to DB
# view: Get a view from DB
# Model.view Schema

# JSON
enableJSON	# enable serializing and parsing from JSON
ignoreJSON= jsonIgnore	# Ignore when parsing & serializing from/to JSON
ignoreFromJSON= jsonIgnoreParsing 	# Ignore when parsing from JSON
ignoreToJSON= jsonIgnoreStringify 	# Ignore when serializing to JSON
toJSON (data)-> data 	# call this fx when serializing
fromJSON (data)-> data	# call this fx when parsing
###*
 * Model
###
MyModel= Model.from(...)
obj= new MyModel()	# create a new Model
obj= MyModel()	# create new Model
obj2= MyModel(obj2) = MyModel.fromDB(obj2) # convert, skip validation
obj2= await MyModel.fromJSON(obj2) # convert obj2 to model & do validation, @throws validationError
obj2= MyModel.fromDB(obj2)	# convert Obj, skip validation
await MyModel.assert(obj)	# do validation, skip object type conversion @throws first validationError, skip warnings

obj instanceOf MyModel	# true

