#=include _const.coffee
#=include _utils.coffee
#=include _params.coffee

# MODEL COMMONS INTERFACE
MODEL_COMMONS=
	#=include model-commons/_*.coffee

# Instances commons
INSTANCE_COMMONS=
	#=include instance-commons/_*.coffee

###*
 * Model class
 * @param {Number} options.maxLoop - Max loop: max loop to rpevent infinit loops
###
class ModelClass
	constructor: (options)->
		@all= {} # Store all Models
		@_maxLoop= options?.maxLoop or DEFAULT_MAX_LOOP
		return
	@_compilers: [] # Store schema directive compilers
	@_types: {}	# Map types (with string name)
	@_typesFx: new WeakMap() # Mapping functions to descriptors
	# PARAMS
	@TO_JSON:	['toJSON']	# ToJSON functions
	@TO_DB:		['toDB']	# ToDB functions
	@COMMONS:	MODEL_COMMONS
	#=include methods/_*.coffee
	<% if(isNode){ %>
	#=include methods-node/_*.coffee
	<% } else { %>
	#=include methods-browser/_*.coffee
	<% } %>
	# FLAGS
	SCHEMA: SCHEMA_SYMB
ModelPrototype= ModelClass.prototype
#=include main/_*.coffee
#=include predefined/_*.coffee
