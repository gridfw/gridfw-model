
### JSON cleaner ###
_toJSONCleaner = (obj, attrToRemove)->
	result = _create null
	for k,v of obj
		result[k] = v unless k in attrToRemove
	_setPrototypeOf result, Object.getPrototypeOf obj
	return result
###*
 * JSON ignore
###
_defineDescriptor
	get:
		jsonIgnore: -> @jsonIgnore = 3 # ignore json
		jsonIgnoreStringify: -> @jsonIgnore = 1 # ignore when serializing
		jsonIgnoreParse: -> @jsonIgnore = 2 # ignore when parsing
		jsonEnable: -> @jsonIgnore = 0 # include this attribute with JSON, @default
	compile: (attr, schema, proto)->
		ignoreJSONAttr = schema[<%= SCHEMA.ignoreJSON %>]
		if ignoreJSONAttr
			ignoreJSONAttr.push attr
		else
			ignoreJSONAttr = schema[<%= SCHEMA.ignoreJSON %>] = [attr]
			_defineProperties proto, toJSON: -> _toJSONCleaner this, ignoreJSONAttr
		return

###*
 * Database persistance
###
_defineDescriptor 'jsonIgnore', get: ->
	@[<%= attrDescriptor.jsonIgnore %>] = 3
	return
