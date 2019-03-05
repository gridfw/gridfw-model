do ->
	#=include index.coffee
	# interface
	window.Model = Model

	# objectId wrapper
	class ObjectId
		constructor: (hexString)->
			throw new Error 'Expected hexString' unless typeof hexString is 'string'
			throw new Error 'Expected hex' unless HEX_CHECK.test hexString
			# attrs
			@_id= hexString
			@_bsontype= 'ObjectID'
			return
		toJSON: -> @_id
		@createFromHexString: (hexString)-> new ObjectId hexString