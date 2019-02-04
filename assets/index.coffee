###*
 * Model
###
<%
#=include template-defines.js
#=include schema.template.js
%>
#=include consts.coffee
#=include utils.coffee

###* Create Model route ###
_schemaDescriptor = _create null
Model = _create _schemaDescriptor,
	all: _create: null # Store all shared models
	
# create private models
_createModelRoot = ->
	mdl = _create Model,
		all: value: _create null
	# return
	mdl

# create new private Models. This will enable to get private model schemas instead of shared ones
_defineProperty Model, 'createPrivate',
	value: _createModelRoot


Model = do _createModelRoot # basic Model


# basic error log
Model.logError = console.error.bind console
Model.warn = console.warn.bind console


# main
#=include main/index.coffee

# schema
#=include schema/index.coffee

# Types
#=include types/index.coffee

# schema inspector for debuging
_modelDescriptorToString = value: -> "Model.#{@[DESCRIPTOR]._pipe.join '.'}"
_defineProperties _schemaDescriptor,
	constructor: value: undefined
	inspect: _modelDescriptorToString
	toString: _modelDescriptorToString
	# toString: value: -> 'MODEL_DESCRIPTOR'
# property name error notifier
_setPrototypeOf _schemaDescriptor, new Proxy {},
	get: (obj, attr) ->
		throw new Error "Unknown Model property: #{attr?.toString?()}" unless typeof attr is 'symbol'
	set: (obj, attr, value) -> throw new Error "Unknown Model property: #{attr?.toString?()}"
