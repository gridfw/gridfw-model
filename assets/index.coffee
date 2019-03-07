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

# create basic Model
Model = _create _schemaDescriptor,
	all: value: _create null # Store all shared models
	newChild: value: ->
		mdle = _create this,
			all: value: _create null # store all Model factories
		return mdle

# coredigix xss
#TODO
xssClean = (data)->
	Model.warn 'Coredigix xss cleaner is missing'
	data

xssEscape = (data)->
	Model.warn 'Coredigix xss cleaner is missing'
	data

# basic error log
Model.logError = console.error.bind console
Model.warn = console.warn.bind console
Model.debug = console.debug.bind console


# main
#=include main/index.coffee

# schema
#=include schema/index.coffee

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

