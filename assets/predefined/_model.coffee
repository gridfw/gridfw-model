###*
 * Nested model
###
ModelClass
.addDirective 'of', 'string', (modelName)->
	@model= modelName
	return
