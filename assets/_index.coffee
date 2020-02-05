###*
 * Model
###
#=include _utils.coffee
ModelAllProxy= get: (_, k)-> throw new Error "Unknown model: #{k}"
class Model
	constructor: ->
		# attrs
		_defineProperties this,
			all: value: _create null
		return
ModelPrototype= Model.prototype