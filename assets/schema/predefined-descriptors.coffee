
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
	# JSON getters
	get:
		jsonIgnore: -> @jsonIgnore = 3 # ignore json, 3 = 11b = ignoreSerialize | ignoreParse
		jsonIgnoreStringify: -> @jsonIgnore = 1 # ignore when serializing: 1= 1b
		jsonIgnoreParse: -> @jsonIgnore = 2 # ignore when parsing: 2 = 10b
		jsonEnable: -> @jsonIgnore = 0 # include this attribute with JSON, @default
	# Compile Prototype and schema
	compile: (attr, descriptor, schema, proto)->
		jsonIgnore = descriptor.jsonIgnore
		# do not serialize attribute
		if jsonIgnore & 1
			ignoreJSONAttr = schema[<%= SCHEMA.ignoreJSON %>]
			if ignoreJSONAttr
				ignoreJSONAttr.push attr
			else
				ignoreJSONAttr = schema[<%= SCHEMA.ignoreJSON %>] = [attr]
				_defineProperties proto, toJSON: -> _toJSONCleaner this, ignoreJSONAttr
		# ignore when parsing
		if jsonIgnore & 2
			#TODO add this to "model.fromJSON"
			(schema[<%= SCHEMA.ignoreParse %>] ?= []).push attr
		return
###*
 * Virtual methods
###
_defineDescriptor
	get:
		virtual: -> @virtual = on
		transient: -> @virtual = on
		persist: -> @virtual = off
	compile: (attr, descriptor, schema, proto)->
		virtualAttr = schema[<%= SCHEMA.virtual %>]
		if virtualAttr
			virtualAttr.push attr
		else
			virtualAttr = schema[<%= SCHEMA.virtual %>] = [attr]
			# implemented for each db engine
			# _defineProperties proto, toDB: -> _toJSONCleaner this, virtualAttr

###*
 * Set attribute as required
###
_defineDescriptor
	get:
		required: -> @required = on
		optional: -> @required = off
	compile: (attr, descriptor, schema, proto)->
		(schema[SCHEMA.required] ?= []).push attr

###*
 * Default value
###
_defineDescriptor
	fx:
		default: (value)->
			throw new Error