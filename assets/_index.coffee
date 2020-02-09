###*
 * Model
###
#=include _const.coffee
#=include _utils.coffee
#=include main/_index.coffee
ModelAllProxy= get: (_, k)-> throw new Error "Unknown model: #{k}"
class BasicModel
ModelPrototype= BasicModel.prototype


###*
 * Main Model interface
###
class Model extends BasicModel
	constructor: ->
		# attrs
		_defineProperties this,
			all: value: _create null
		return
	###*
	 * Define new Model
	###
	define: (modelName, schema)->
		# checks
		throw new Error "Model name expected string" unless typeof modelName is 'string'
		throw new Error "Model alreay set: #{modelName}" if @all.hasOwnProperty modelName 
		# prepare schema
		schema= Model.value schema
		# Model
		model = (instance)->
			# check for "new" operator
			if `new.target`
				throw new Error "Remove arguments or [new] operator" if arguments.length
				return
			# convert instance
			switch arguments.length
				when 0
					return new model()
				when 1
					return model.fromDB instance
				else
					throw new Error "Illegal arguments"
		# prototype
		model.prototype = schema[<%= SCHEMA.prototype %>]
		model[SCHEMA] = schema
		# set model name
		_defineProperties model,
			name: value: modelName
			Model: value: this
		# Model statics
		_setPrototypeOf model, ModelCommons
		# add to registry
		_defineProperty @all, modelName,
			value: model
			enumerable: yes
		# return
		return model