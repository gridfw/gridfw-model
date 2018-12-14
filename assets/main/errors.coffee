### Error ###
class SchemaError extends Error
	constructor: (message, errorsList)->
		super message
		@errors = errorsList
	toString: -> "#{@message}\n#{@details}"
	inspect: -> "#{@message}\n#{@details}"

_defineProperty SchemaError.prototype, 'details', get: ->
	msg = [@message]
	for err in @errors
		er = err.error
		msg.push "@#{err.path.join('.')}>> #{er?.stack || er}"
	msg.join "\n"