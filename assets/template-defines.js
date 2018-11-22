/**
 * This file contains templating configurations
*/

/**
 * Assert arguments length
 * @example
 * assertArgsLength(2) # assert arguments are 2
 * assertArgsLength(2, 3, 4) # assert arguments are 2, 3 or 4
 * assertsArgsLengthBetween(2, 3) # assert args length are beween 2 and 3
*/
function assertArgsLength(a){
	if(arguments.length === 1)
		return 'throw new Error "Illegal arguments" unless arguments.length is ' + a
	else
		return 'throw new Error "Illegal arguments" unless arguments.length in [' + Array.from(arguments).join(',') + ']'
}