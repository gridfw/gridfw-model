### Error ###
class SchemaError
	constructor: (@message, @errors)->
	toString: -> "#{@message}\n#{@details}"
	inspect: -> "#{@message}\n#{@details}"

_defineProperty SchemaError.prototype, 'details', get: ->
	msg = [@message]
	for err in @errors
		er = err.error
		msg.push "@#{err.path.join('.')}>> #{er?.stack || er}"
	msg.join "\n"