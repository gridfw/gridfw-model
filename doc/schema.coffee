###*
 * Create schema for your Model
###
model = Model.from
	name	: 'modelName'
	schema	: modelSchema
	# static properties
	static	:
		staticFx: ->{}
		staticAttr: 'value'

# add static properties
model.staticFunction = -> {} 
model.staticAttribute= 'value'

###*
 * Add values to existant schema
 * existant values will be overrided
###
model = Model.override
	name	: 'modelName'
	schema	: overridedSchema

###*
 * Extend schema
###
childModel = Model.extend
	name	: 'modelName'
	from	: 'parentName'
	schema	: childSchema # @optional

###*
 * Make snapshot from a schema
###
Model.snapshot
	name	: 'snapName'
	from	: 'srcModelName'
	schema	: snapSchema

###*
 * Get created model class
###
Model.get 'modelName'

###*
 * Create instance
###
model = Model.from ...
instance = model() # create new instance of model
instance = new model() # create new instance of model
instance = model {} # create new instance of model
instance instanceof model # true
instance instanceof Model # true

instance = new Model() # create generic instance
instance = Model() # create generic instance
instance = Model {} # create generic instance

###*
 * Convert a plain object to be of type model
 * (nested documents will be affected too)
###
instance = {...}
model(instance) # after this line, "instance" will be an instance of "model"

###*
 * Create costom types
###
Model.type
	name: 'TypeName' # Name of the type, shoold be CamelCase, the first caracter mast be upercased
	name: TypeName # if this type is represented with a class, example: String, Boolean, ...
	check: (value)-> # check logic, returns true or false
	convert: (value)-> value # convert value, throws error when value could not be converted


###*
 * Schema
###
modelSchema = Model.extensible.value(subModelSchema)
modelSchema = [subModelSchema] # list of ...
modelSchema = Model.list(subModelSchema) # list of ...
modelSchema = 
	# Simple type
	attribute1_0: Boolean# true or false
	attribute1_1: String	# String with length < 3000, HTML will be escaped
	attribute1_2: Number	# Number
	attribute1_3: Date		# Date
	attribute1_4: Buffer	# Buffer
	attribute1_4: Map		# Map, always json ignore
	attribute1_4: Set		# Set, will be converted to list when serializing as JSON
	attribute1_4: WeakSet	# WeakSet, always json ignore
	attribute1_4: WeakMap	# WeakMap, always json ignore

	# Advanced Types
	attribute2_0: Model.Boolean	# same as Boolean
	attribute2_1: Model.String	# same as String
	attribute2_2: Model.Number	# same as Number
	attribute2_2: Model.Date	# same as Date
	attribute2_2: Model.Buffer	# same as Date
	attribute2_2: Model.Map		# same as Map
	attribute2_2: Model.Set		# same as Set
	attribute2_2: Model.WeakMap	# same as WeakMap
	attribute2_2: Model.WeakSet	# same as WeakSet
	attribute2_3: Model.Int		# integer
	attribute2_4: Model.Unsigned# unsigned integer
	attribute2_4: Model.Hex		# string representing a hex number

	attribute2_5: Model.HTML		# html, images and js and dangerous code will be removed
	attribute2_6: Model.HTMLImgs	# html, keep images, remove dangerous code
	attribute2_7: Model.Email		# valid Email
	attribute2_8: Model.Password	# password with length between 8 and 100

	attribute2_9: Model.ObjectId	# MongoDB objectid
	attribute2_9: Model.UUID		# UUID

	attribute2_10: Model.Mixed		# @default, mixed type

	attribute2_10: Model.CustomType		# type registred with "Model.type" method

	# default value
	attribute3_0: Model[type].default(8) # static value as default value, could be of any type unless functions (string, number, boolean, array, object)
	# Dynamic generate default value when first call
	# @param obj - current object
	attribute3_1: Model[type].default((obj)->{})
	attribute3_2: Model[type].default(Date.now) # set function to generate default value
	attribute3_3: Date.now	 # very special case, set default value to date.now

	# require attribute
	attribute3_1: Model.required
	# optional attribute
	attribute3_1: Model.optional

	attr: Model.freeze.value(subSchema)# Accept only listed attributes, remove other properties
	attr: Model.extensible.value(subSchema)# Accept other values
	# marque all attributes as required

	# JSON manipulation
	attribute3	: Model.jsonIgnore # ignore this field when serializing or parsing as json
	attribute3	: Model.jsonIgnoreStringify # ignore this field when serializing as json
	attribute3	: Model.jsonIgnoreParse # ignore this field when parsing as json
	attribute3	: Model.jsonEnable # Enable JSON serialization @default

	# save to data base
	attribute3	: Model.virtual	# do not save to database
	attribute3	: Model.transient# alias to virtual
	attribute3	: Model.persist	# force to save to database

	# list
	attribute3: [Number] # list of numbers
	attribute3: [Model.Int] # list of integers
	attribute3: [nestedSchema] # list of integers
	attribute3: Model.list(Number) # list of numbers
	attribute3: Model.list(nestedSchema) # list of numbers
	attribute3: Model.required.list(Number) # required list of numbers
	attribute3: Model.required.list Number, # required list of numbers
		method1: fx, # method on the list
		method2: fx, # method 2 on the list
		staticValue: 14 # static value, string, number, boolean
		getter: Model.getter(fx)	# getter
		setter: Model.setter(fx)	# setter
		getterOnce: Model.default(fx)	# getter once
		alias: Model.alias('attr')	# alias
	# Nested objects
	attribute4_0: subModelSchema # sub model schema for nested object
	attribute4_1: Model.required.value(subModelSchema) # required nested object
	attribute4_1: Model.get 'modelName' # get this model as submodel

	# reference to an other model
	# the deference with "get" is get will be added as nested object
	attribute5_0: Model.ref 'modelName'

	# snapshot to an other model
	attribute6_0: Model.snapshot 'snapshotName'
	attribute6_0: Model.snapshot
		from: 'modelName'
		schema: snapshotSchema

	# add methods
	methodAttribue: (arguments) -> {}
	# getter
	getterAttribue: Model.getter(->{})
	# setter
	setterAttribute: Model.setter((value) -> {this.kkkk = value})
	# getter for first time only (cache value for future calls)
	defaultValueAttribute: Model.default(->{})

	# alias to an other attribute
	# @example
	# * {
	# *		id: Model.alias('_id')
	# *		_id: Model.ObjectId
	# * }
	aliasAttr: Model.alias('attrName') # same as Model.getter(-> this.attrName)
	aliasAttr: Model.alias(-> getter_expr) # some as Model.getter(->)
	aliasAttr: Model.alias(getter_expr, setter_expr) # some as Model.getter(->).setter(->)



	# assertions
	attr: Model.assert(true, 'Optional error message') # assert value equals to a static value (string, boolean, number, ...)
	attr: Model.assert((value)-> true | false) # assertion
	attr: Model.assert(async (value)-> true | false) # could use async function
	attr: Model.assert(assertion1).assert(assertion2) # could use multiple assertions
	attr: Model.assert(assertion1, assertion2, ...) # could use multiple assertions
	attr: Model.assert([assertion1, assertion2, ...]) # could use multiple assertions
	attr: Model[type].assert
		min: 415		# alt to .min(415)
		max: 122214		# alt to .max(122214)
		length: 1425	# when string, length must equals this
		match: /regex/i


	# length
	attr: Model.String.length(123) # assert string length is 123
	attr: Model.String.min(123) # assert string length >= 123
	attr: Model.String.max(2000) # assert string length <= 2000
	attr: Model.String.between(12, 2000) # assert string length between 12 and 2000
	attr: Model.String.match(/regex/) # match

	attr: Model.Number.min(123) # assert value >= 123
	attr: Model.Number.max(2000) # assert value <= 2000
	attr: Model.Number.between(12, 2000) # assert value between 12 and 2000

	attr: Model.Date.min(date1) # assert date greater then date1
	attr: Model.Date.max(date2) # assert date less then date2
	attr: Model.Date.between(date1, date2) # assert date between date1 and date2

	attr: Model.Number
			.max 12542
			.min 5
			.default 45

	# post traitement
	# @example
	# * attr: Model.String.pipe(value-> value.toUpperCase().trim())
	attr: Model.pipe(->) # do processing on the value
	attr: Model.pipe(process1).pipe(process2)
	# string manipulation
	