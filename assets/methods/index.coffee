###*
 * Model descriptor methods
###
_ModelMethods = Object.create null

###*
 * descriptor wrapper
###
<%
	#=include default-descriptor.template.js
%>
_defaultDescriptor = ->
	arr = <%= JSON.stringify(attrDescTable) %>
	Object.setPrototypeOf arr, _ModelMethods
	return arr
	
_defineDescriptorWrapper = (fx) ->
	->
		arr = this
		arr = _defaultDescriptor() if arr is Model
		# exec fx
		fx.apply arr, arguments
		# chain
		arr

###*
 * define descriptor methods
###
_defineDescriptor = (name, desc) ->
	# value
	if 'value' of desc
		desc.value = _defineDescriptorWrapper desc.value
	else if 'get' of desc
		desc.get = _defineDescriptorWrapper desc.get
	# define value
	Object.defineProperty _ModelMethods, name, desc