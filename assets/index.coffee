###*
 * Model
###
_create = Object.create
###* Create Model descriptor ###
ModelD = _create null

<%
#=include template-defines.js
#=include schema.template.js
%>
#=include consts.coffee
#=include utils.coffee

### Model.all ###
_allToString= -> "Models[#{Reflect.ownKeys(this).join ', '}]"
ALL_PROXY_DESCRIPTOR=
	get: (obj, attr) ->
		if typeof attr is 'string'
			attrL= attr.toLowerCase()
			if obj.all.hasOwnProperty attrL
				throw new Error "Please use lower-case names to access Models: [#{attrL}] instead of [#{attr}]"
			else
				throw new Error "Unknown Model: #{attr}"
		return
	set: (obj, attr, value) -> throw new Error "Please don't set values manually to this object!"
class Model
	constructor: ->
		# all repositories queu
		allRepo= _create (new Proxy this, ALL_PROXY_DESCRIPTOR),
			constructor: value: undefined
			inspect: value: _allToString
			toString: value: _allToString
			hasOwnProperty: value: Object.hasOwnProperty
		# attrs
		_defineProperties this,
			all: value: allRepo
		return

# Model Prototype
ModelP= Model.prototype

# static functions
ModelP.logError= console.error.bind console
ModelP.warn= console.warn.bind console
ModelP.debug= console.debug.bind console

# set ModelD as Model.prototype.__proto__
_setPrototypeOf ModelP, ModelD

# coredigix xss
#TODO
xssCleanNoImages = (data)->
	# if xssClean?
	# 	xssCleanNoImages= (data) -> xssClean data, imgs: off
	# 	return xssCleanNoImages(data)
	# else
	ModelP.warn 'Coredigix xss cleaner is missing'
	data
xssCleanWithImages = (data)->
	# if xssClean?
	# 	xssCleanNoImages= (data) -> xssClean data, imgs: on
	# 	return xssCleanNoImages(data)
	# else
	ModelP.warn 'Coredigix xss cleaner is missing'
	data

xssEscape = (data)->
	ModelP.warn 'Coredigix xss cleaner is missing'
	data

# main
#=include main/index.coffee

# schema
#=include schema/index.coffee

# schema inspector for debuging
_modelDescriptorToString = value: -> "Model Descriptor ()" # TODO
_defineProperties ModelD,
	constructor: value: undefined
	inspect: _modelDescriptorToString
	toString: _modelDescriptorToString
	hasOwnProperty: value: Object.hasOwnProperty
	# toString: value: -> 'MODEL_DESCRIPTOR'
# property name error notifier
_setPrototypeOf ModelD, new Proxy {},
	get: (obj, attr) ->
		throw new Error "Unknown Model property: #{attr?.toString?()}" unless typeof attr is 'symbol'
	set: (obj, attr, value) -> throw new Error "Please, don't set values manually to this object!"

