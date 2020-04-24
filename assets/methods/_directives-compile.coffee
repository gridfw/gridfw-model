###*
 * Compile directives
 * @param {function} cb(schema, attr, attrIndex, prototype) - Callback
###
@compileAttrDirective: (cb)->
	@_compilers.push cb
	this # chain
