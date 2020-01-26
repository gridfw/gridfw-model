###*
 * Checkers
###
# _CHECK_IS_OBJECT= (data)-> typeof data is 'object' and not Array.isArray data
_checkIsUnsigned= (value)->throw new Error "Expected positive integer" unless Number.isSafeInteger(value) and value >= 0
###*
 * Predefined types
###
Model.directives
	# OBJECT
	Object:
		fx: Object
		d: -> @.check (data)-> typeof data is 'object' and not Array.isArray data
	# LIST
	List:
		alt: ['Array']	# aliases to List
		fx: Array	# Function representing list
		d: ->	# directive apply
			@check Array.isArray data
			.convert (data)-> if data? then [data] else []
		asserts:
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