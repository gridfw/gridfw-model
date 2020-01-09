###*
 * Commun array prototype
###
_arrayProto = _create Array.prototype,
	push: value: ->
		values = Array.from arguments
		# convert all types
		# for value in values

		# push
		_ArrayPush.apply this, values


### Common plain object prototype ###
_plainObjPrototype = {}


# Model proto
_docObjProto = _create _plainObjPrototype
_docArrProto = _create _arrayProto