###*
 * Define new schema
###
define: (modelName, schema)->
	# checks
	throw new Error "Model name expected string" unless typeof modelName is 'string'
	throw new Error "Model already set: #{modelName}" if _has @all, modelName
	# Compile schema
	return @_compileSchema modelName, schema

###*
 * Override existing schema
###
override: (modelName, schema)->
	throw new Error "Unknown Model: #{modelName}" unless model = @all[modelName]
	# Compile schema
	#TODO enable to overide event not yeat implemented!
	return @_compileSchema modelName, schema

###*
 * Extends existing model
###
extends: (modelName, parentModelName, schema)->
	# checks
	throw new Error "Model name expected string" unless typeof modelName is 'string'
	throw new Error "Model already set: #{modelName}" if _has @all, modelName
	throw new Error "Unknown Model: #{parentModelName}" unless parentModel = @all[parentModelName]
	# copy model schema
	model= @_loadModel modelName
	model[SCHEMA_SYMB]= @_cloneSchema(parentModel)
	# Override
	return @_compileSchema modelName, schema
	
