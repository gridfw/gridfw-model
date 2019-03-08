###*
 * Print model schema as tree
###
# interface
_defineProperty ModelStatics, 'modelSignature', value: do ->
	# recursive print
	_printSchemaJSONDirectives= ['jsonEnable', 'jsonIgnoreStringify', 'jsonIgnoreParse', 'jsonIgnore']
	_recursivePrint= (level, queue, schema)->
		indent= "\t".repeat level++
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
			else if nextSchema= schema[i+ <%= SCHEMA.attrSchema %>]
				# freezed
				ref= nextSchema[<%= SCHEMA.extensible %>]
				if ref is yes
					queue.push '.extensible'
				else if ref is no
					queue.push '.freeze'
				# rec print
				if nextSchema[<%= SCHEMA.schemaType %>] is <%= SCHEMA.LIST %>
					queue.push " [\n"
					_recursivePrint level, queue, nextSchema
					queue.push indent, "]\n"
				else
					queue.push "\n"
					_recursivePrint level, queue, nextSchema
			else
				queue.push "\n"
		return
	# interface
	->
		queue= []
		# prepare
		sq= []
		schema= @[SCHEMA]
		sq[<%= SCHEMA.schemaType %>] = <%= SCHEMA.OBJECT %>
		sq[<%= SCHEMA.sub + SCHEMA.attrName %>]= "Model #{@name}"
		sq[<%= SCHEMA.sub + SCHEMA.attrType %>]= if schema[<%= SCHEMA.schemaType %>] is <%=SCHEMA.LIST %> then 'List' else 'Object'
		sq[<%= SCHEMA.sub + SCHEMA.attrSchema %>]= schema
		# print
		_recursivePrint 0, queue, sq
		return queue.join ''
