###*
 * Main model
###
# Model = (instance)->
# 	# new generic instance
# 	if `new.target`
# 		# could not use "new" operator and arguments in the same time
# 		throw new Error "Remove arguments or [new] operator" if arguments.length
# 		return
# 	# use withoud "new" operator
# 	else unless arguments.length
# 		instance = Object.create Model.prototype
# 	else if arguments.length is 1 and typeof instance is 'object' and instance
# 		Object.setPrototypeOf instance, Model.prototype
# 	else
# 		throw new Error "Illegal arguments"
# 	return instance
# static protoperties
ModelStatics = _create Function.prototype,
	toString: value: -> "[Model #{@name}]"

### Add symbols ###
_defineProperties Model,
	SCHEMA: value: SCHEMA # link object to it's schema
	TYPE_ATTR: value: TYPE_ATTR


#=include plugin.coffee
#=include errors.coffee
#=include basic-proto.coffee
#=include from-schema.coffee
#=include instance-from.coffee
#=include utilities.coffee