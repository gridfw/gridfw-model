###*
 * Add Model plugin
###
_defineProperty Model, 'plugin', value: (options)->
	<%= assertArgTypes('plugin', 'plain object') %>
	throw new Error 'plugin>> Argument is null' unless options
	# Model properties
	if 'Model' of options
		_defineProperties Model, Object.getOwnPropertyDescriptors options.Model

	# Model factory properties
	if 'model' of options
		_defineProperties ModelStatics, Object.getOwnPropertyDescriptors options.model

	# Document properties
	if 'doc' of options
		_defineProperties _docObjProto, Object.getOwnPropertyDescriptors options.doc
		_defineProperties _docArrProto, Object.getOwnPropertyDescriptors options.doc
	if 'docObj' of options
		_defineProperties _docObjProto, Object.getOwnPropertyDescriptors options.docObj
	if 'docArr' of options
		_defineProperties _docArrProto, Object.getOwnPropertyDescriptors options.docArr

	# all object
	if 'obj' of options
		_defineProperties _plainObjPrototype, Object.getOwnPropertyDescriptors options.obj

	# all arrays
	if 'arr' of options
		_defineProperties _arrayProto, Object.getOwnPropertyDescriptors options.arr
	return


