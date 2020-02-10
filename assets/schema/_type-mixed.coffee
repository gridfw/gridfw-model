###*
 * Basic type
###
_Mixed=
	_type: null # No basic type
	_typeName: 'Mixed'
	_check: -> true
	_convert: (data)-> data

_defineProperty Model, 'Mixed', get: ->
	if _has this, 'all'
		result= _create _modelPrototype,
			_assertVl:	value: {} # asserts
			_pipe:		value: [] # pipeline
			_pipeOnce:	value: [] # pipeOnce
			_proto:		value: {} # prototype
			_type:
				value: _Mixed	# basic type
				configurable: yes
				writable: yes
	else
		@_type= _Mixed
		result= this
	return result
