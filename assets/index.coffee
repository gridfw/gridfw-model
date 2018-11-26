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

	# interface
	<% if(mode === 'node'){ %>
	module.exports = Model
	<% } else { %>
	window.Model = Model
	<% } %>