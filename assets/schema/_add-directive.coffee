# Directive wrapper
_directiveWrapper= (directive)->
	if @hasOwnProperty 'all' # Model
		obj= _create ModelPrototype,
			_assertVl: value: {} # asserts
			_pipe: value: [] # pipeline
			_pipeOnce: value: [] # pipeOnce
			_proto: value: {} # prototype
			_type:
				value: _Mixed	# basic type
				configurable: yes
	else
		obj= this
	return obj