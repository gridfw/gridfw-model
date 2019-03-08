###*
 * Print model schema as tree
###
_printSchemaTree= ->
	queue= ['Model ', @name, ":\n"]
	_printSchemaNode 1, queue, @[SCHEMA]
	return queue.join ''

_printSchemaNode= (level, queue, schema)->
	indent= "\t".repeat level++
	# print 
	if schema[<%= SCHEMA.schemaType %>] is <%= SCHEMA.OBJECT %>
		queue.push "\n"
		_printSchemaNodeObject indent, level, queue, schema
	else if schema[<%= SCHEMA.schemaType %>] is <%= SCHEMA.LIST %>
		queue.push "[\n"
		_printSchemaNodeList indent, level, queue, schema
		queue.push indent, "]\n"
	else
		queue.push "\n", indent, '<INVALID>'
	return

# object
_printSchemaJSONDirectives= ['jsonEnable', 'jsonIgnoreStringify', 'jsonIgnoreParse', 'jsonIgnore']
_printSchemaNodeObject= (indent, level, queue, schema)->
	# add attributes
	j = <%= SCHEMA.sub %>
	len = schema.length
	while j < len
		# next
		i = j
		j+= <%= SCHEMA.attrPropertyCount %>
		# info
		queue.push indent, schema[i], ": "
		# type
		if ref= schema[i + <%= SCHEMA.attrType %>]
			queue.push ref
		# required
		if schema[i+<%= SCHEMA.attrRequired %>]
			queue.push '.required'
		# virtual
		if schema[i+<%= SCHEMA.attrVirtual %>]
			queue.push '.virtual'
		# freezed
		if schema[i+<%= SCHEMA.attrExtensible %>] is no
			queue.push '.freeze'
		# json ignore
		if typeof (ref= schema[i+<%= SCHEMA.attrJSONIgnore %>]) is 'number'
			queue.push '.', _printSchemaJSONDirectives[ref]
		# predefined asserts
		ref= schema[i + <%= SCHEMA.attrPropertyAsserts %>]
		if ref
			refI= 0
			refLen= ref.length
			refQ= []
			while refI < refLen
				refQ.push "#{ref[refI++]}: #{ref[refI++]}"
				refI++
			queue.push '.assert( ', refQ.join(', '), ' )'
		# asserts count
		ref= schema[i + <%= SCHEMA.attrAsserts %>]
		if ref
			refI= 0
			refLen= ref.length
			while refI < refLen
				queue.push  '.assert(', ref[refI].name || '<Fx>', ')' # asserts count
				++refI
		# pipe count
		ref= schema[i + <%= SCHEMA.attrPipe %>]
		if ref
			refI= 0
			refLen= ref.length
			while refI < refLen
				queue.push '.pipe(', ref[refI].name || '<Fx>', ')' # asserts count
				++refI

		# info
		# next
		if ref= schema[i+<%= SCHEMA.attrRef %>]
			queue.push "<REF: ", ref, ">\n"
		else if ref= schema[i+ <%= SCHEMA.attrSchema %>]
			_printSchemaNode level, queue, ref
			# if ref[<%= SCHEMA.schemaType %>] is <%= SCHEMA.LIST %>
			# 	queue.push "[\n"
			# 	_printSchemaNode level, queue, ref
			# 	queue.push indent, "]\n"
			# else
			# 	queue.push "\n"
			# 	_printSchemaNode level, queue, ref
		else
			queue.push "\n"
	return
# list
_printSchemaNodeList= (indent, level, queue, schema)->
	# reference
	if ref= schema[<%= SCHEMA.listRef %>]
		queue.push indent, '<REF: ', ref, ">\n"
	# nested
	else if ref= schema[<%= SCHEMA.listSchema %>]
		_printSchemaNode level, queue, ref
	# simple type
	else
		queue.push indent, schema[<%= SCHEMA.listType %>], "\n"
	return

# interface
_defineProperty ModelStatics, 'modelSignature', value: _printSchemaTree