###*
 * Create schema for your Model
###
model = Model.from
	name	: 'modelName'
	schema	: modelSchema

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
 * Schema
###
modelSchema =
	# Simple type
	attribute1_0: Boolean# true or false
	attribute1_1: String	# String with length < 3000, HTML will be escaped
	attribute1_2: Number	# Number

	# Advanced Types
	attribute2_0: Model.Boolean	# same as Boolean
	attribute2_1: Model.String	# same as String
	attribute2_2: Model.Number	# same as Number
	attribute2_3: Model.Int		# integer
	attribute2_4: Model.Unsigned # same as unsigned integer
	attribute2_4: Model.Hex		# string representing a hex number

	attribute2_5: Model.HTML		# html, images and js and dangerous code will be removed
	attribute2_6: Model.HTMLImgs	# html, keep images, remove dangerous code
	attribute2_7: Model.Email		# valid Email
	attribute2_8: Model.Password	# password with length < 100

	attribute2_9: Model.ObjectId	# MongoDB objectid
	attribute2_9: Model.UUID		# UUID


	# Nested objects
	attribute: subModelSchema # sub model schema for nested object

