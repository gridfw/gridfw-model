###*
 * Predifined directive wrappers
###

# assert
Model
	.directives
		length: (value)-> @assert length: value
		min:	(min)-> @assert min: min
		max:	(max)-> @assert max: max
		between:(min, max)-> @assert min: min, max: max
		match:	(min, max)-> @assert min: min, max: max
