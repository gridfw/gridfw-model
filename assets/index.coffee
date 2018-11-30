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
	
	# property name error notifier
	_setPrototypeOf _schemaDescriptor, new Proxy {},
		get: (obj, attr) -> throw new Error "Unknown Model property: #{attr}"
		set: (obj, attr, value) -> throw new Error "Unknown Model property: #{attr}"

	# interface
	<% if(mode === 'node'){ %>
	module.exports = Model
	<% } else { %>
	window.Model = Model
	<% } %>