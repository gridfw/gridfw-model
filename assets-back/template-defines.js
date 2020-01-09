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
function assertArgsLength(fxName, len){
	if(arguments.length === 1)
		return `throw new Error "${fxName}>> Expected ${len} arguments" unless arguments.length is ${len}`;
	else
		var acceptedArgCount = Array.from(arguments).slice(1);
		return `throw new Error "${fxName}>> Expected ${acceptedArgCount.join(' or ')} arguments" unless arguments.length in [${acceptedArgCount.join(',')}]`
}

var _ASSERT_TYPES= ['object', 'function', 'string', 'number', 'boolean']
function assertArgTypes(fxName){
	var argc = arguments.length;
	var reqArgs= argc-1
	var code= [`throw new Error '${fxName}>> Expected ${reqArgs} arguments' unless arguments.length is ${reqArgs}`];
	var tp;
	for(var i=0; i<reqArgs; i++){
		tp = arguments[i+1];
		if(typeof tp === 'string')
			if(tp === 'plain object')
				code.push(
					`argv=arguments[${i}]`,
					`throw new Error "${fxName}>> Arguments[${i}] expected plain object" unless typeof argv is 'object' and argv and not Array.isArray argv`
				);
			else if(_ASSERT_TYPES.indexOf(tp) != -1)
				code.push(`throw new Error "${fxName}>> Arguments[${i}] expected ${tp}" unless typeof arguments[${i}] is ${tp}`);
			else
				throw new Error(`Unsupported type: ${tp}`);
		else
			code.push(`throw new Error "${fxName}>> Arguments[${i}] expected in [${tp.join(', ')}] " unless typeof arguments[${i}] in ${JSON.stringify(tp)}`);

	}
	return code.join("; ");
}