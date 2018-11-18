
###*
 * JSON ignore
###
_defineDescriptor 'jsonIgnore', get: ->
	@[<%= attrDescriptor.jsonIgnore %>] = 3
	return
_defineDescriptor 'jsonIgnoreStringify', get: ->
	@[<%= attrDescriptor.jsonIgnore %>] = 1
	return
_defineDescriptor 'jsonIgnoreParse', get: ->
	@[<%= attrDescriptor.jsonIgnore %>] = 2
	return
_defineDescriptor 'jsonEnable', get: ->
	@[<%= attrDescriptor.jsonIgnore %>] = 0
	return

###*
 * Database persistance
###
_defineDescriptor 'jsonIgnore', get: ->
	@[<%= attrDescriptor.jsonIgnore %>] = 3
	return