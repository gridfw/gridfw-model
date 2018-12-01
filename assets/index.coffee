do ->
	###*
	 * Model
	###
	#=include consts.coffee
	_schemaDescriptor = _create null
	Model = _create _schemaDescriptor

	# basic error log
	Model.logError = console.error.bind console

	<%
	#=include template-defines.js
	#=include schema.template.js
	%>

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

	# interface
	<% if(mode === 'node'){ %>
	module.exports = Model
	<% } else { %>
	window.Model = Model
	<% } %>