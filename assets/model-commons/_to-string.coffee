###*
 * Render Model to string
 * ├─
 * │
 * └─
###
toString: do ->
	# params
	ATTR_SPACING= 15
	EXTRACT_FX_REGEX= /^function[^(]*\(.*?\)/
	# const
	PROCESS_NODE		= 0
	PROCESS_ATTRIBUTE	= 1
	# print attribute
	_resolveAttr= (node, index)->
		result= []
		# type
		if nestedNode= node[<%- SCHEMA_ATTR.nested %>+index]
			switch nestedNode[<%- SCHEMA.format %>]
				when <%-SCHEMA.OBJECT %>
					result.push "Model.value(OBJECT)"
				when <%-SCHEMA.LIST %>
					result.push "[]"
					nestedNode= nestedNode[<%- SCHEMA.length+SCHEMA_ATTR.nested %>]
				when <%-SCHEMA.MAP %>
					result.push "Model.map(#{_resolveAttr(nestedNode, <%- SCHEMA.length %>)}, #{_resolveAttr(nestedNode, <%- 2*SCHEMA.length %>)})"
					nestedNode= nestedNode[<%- 2*SCHEMA.length+SCHEMA_ATTR.nested %>]
				when <%- SCHEMA.LINK %>
					result.push "Model.of('#{nestedNode[<%- SCHEMA.model %>].name}')"
				else
					result.push 'Model'
		else if type= node[<%- SCHEMA_ATTR.type %>+index]
			if type.fx
				result.push type.typeName
			else
				result.push 'Model.', type.typeName
		else
			result.push 'Model'
		# flags
		flags= node[<%- SCHEMA_ATTR.flags %>+index]
		# JSON
		switch flags&3
			when 1
				result.push '.ignoreJsonStringify'
			when 2
				result.push '.ignoreJsonParse'
			when 3
				result.push '.ignoreJSON'
		# required
		if flags&<%-SCHEMA.IS_FREEZE_SET %> and node[<%- SCHEMA_ATTR.nested %>+index]
			if flags&<%-SCHEMA.FREEZE %>
				result.push '.freeze'
			else
				result.push '.extensible'
		result.push '.virtual' if flags&<%-SCHEMA.VIRTUAL %>
		result.push '.required' if flags&<%-SCHEMA.NOT_NULL %>
		# default
		if vl= node[<%- SCHEMA_ATTR.default %>+index]
			vl = "#{vl.toString().match(EXTRACT_FX_REGEX)?[0] or 'function'}{...}" if typeof vl is 'function'
			result.push ".default(#{vl})"
		# Asserts
		vl= node[<%- SCHEMA_ATTR.asserts %>+index]
		i= 0
		len= vl.length
		while i<len
			if vl2= vl[i]
				result.push ".#{vl2}(#{vl[i+1]})"
			else
				result.push ".assert(...)"
			i+= 4
		# Pipe
		result.push ".pipe(...)" if node[<%- SCHEMA_ATTR.pipe %>+index]?.length
		return result.join ''
	# Interface
	return ->
		###*
		 * Seek non recursive: [node, processType, level, index, isLastAttribute]
		 * processType:
		 * 		0: Node
		 * 		1: Object attribute
		 * 		2: List
		###
		nodes= [@[SCHEMA_SYMB], 0, "\n", 0, no] # 
		seekI= 0
		maxLoop= @_maxLoop # Maximum seeks
		result= ["#{@name}: "]
		while nodes.length
			throw "Max loop exceeded: #{maxLoop}" if ++seekI >= maxLoop
			# Load data
			isLastAttr	= nodes.pop()
			index		= nodes.pop()
			levelStr	= nodes.pop()
			processType	= nodes.pop()
			node		= nodes.pop()
			# process
			switch processType
				# Node
				when PROCESS_NODE
					# Format
					switch node[<%- SCHEMA.format %>]
						when <%- SCHEMA.ROOT %>
							# new line
							result.push levelStr
							modelName= " #{node[<%-SCHEMA.model %>]} "
							modelDesc= " #{_resolveAttr node, <%- SCHEMA.length %>} "
							result.push levelStr, '╔', '═'.repeat(modelName.length), '╦', '═'.repeat(modelDesc.length), '╗',
										levelStr, '║', modelName, '║', modelDesc, '║',
										levelStr, '╚', '═'.repeat(modelName.length), '╩', '═'.repeat(modelDesc.length), '╝'
							if nestedNode= node[<%- SCHEMA.length+SCHEMA_ATTR.nested %>]
								nodes.push nestedNode, PROCESS_NODE, levelStr+"\t", 0, no
						when <%- SCHEMA.OBJECT %>
							# result.push 'Model.value'
							# Show attributes
							i= node.length - <%- SCHEMA_ATTR.length %>
							isLast= yes
							while i >= <%- SCHEMA.length %>
								nodes.push node, PROCESS_ATTRIBUTE, levelStr, i, isLast
								isLast= no
								i-= <%- SCHEMA_ATTR.length %>
						when <%- SCHEMA.LIST %>
							# new line
							result.push levelStr
							result.push "╚═ [#{_resolveAttr node, <%- SCHEMA.length %>}]"
							if nestedNode= node[<%- SCHEMA.length+SCHEMA_ATTR.nested %>]
								nodes.push nestedNode, PROCESS_NODE, levelStr+"\t", 0, no
						when <%- SCHEMA.MAP %>
							result.push levelStr
							result.push "╚═ Model.map(#{_resolveAttr node, <%- SCHEMA.length %>})"
							if nestedNode= node[<%- 2*SCHEMA.length+SCHEMA_ATTR.nested %>]
								nodes.push nestedNode, PROCESS_NODE, levelStr+"\t", 0, no
						when <%- SCHEMA.LINK %>
							str= " Model.of('#{node[<%- SCHEMA.model %>].name}') "
							result.push levelStr, '║ ╔', '═'.repeat(str.length), "╗", levelStr,
													'╚═╣', str, '║', levelStr,
													'  ╚', '═'.repeat(str.length), '╝'
						else
							throw new Error "Inexpected format: #{node[<%- SCHEMA.format %>]}"
				when PROCESS_ATTRIBUTE
					# new line
					result.push levelStr
					# attribute name
					vl= node[<%- SCHEMA_ATTR.name %>+index]
					nsp= ATTR_SPACING - vl.length
					nsp= 0 if nsp<0
					result.push (if isLastAttr then '└─ ' else '├─ '), node[<%- SCHEMA_ATTR.name %>+index], ' '.repeat(nsp), ": "
					levelStr= levelStr+ (if isLastAttr then "\t" else "│\t")
					# if map or list
					result.push _resolveAttr node, index
					# nested
					if nestedNode= node[<%- SCHEMA_ATTR.nested %>+index]
						nodes.push nestedNode, PROCESS_NODE, levelStr, 0, no
					# nestedI= 0
					# `nNode://`
					# while nestedNode
					# 	throw new Error "Max loop exceeded: #{maxLoop}" if ++nestedI >= maxLoop
					# 	switch nestedNode[<%- SCHEMA.format %>]
					# 		when <%-SCHEMA.OBJECT %>
					# 			nodes.push nestedNode, PROCESS_NODE, levelStr, 0, no
					# 			`break nNode`
					# 		when <%-SCHEMA.LIST %>
					# 			nestedNode= nestedNode[<%- SCHEMA.length+SCHEMA_ATTR.nested %>]
					# 		when <%-SCHEMA.MAP %>
					# 			nestedNode= nestedNode[<%- 2*SCHEMA.length+SCHEMA_ATTR.nested %>]
					# 		when <%- SCHEMA.LINK %>
					# 			nestedNode= null
					# 		else
					# 			throw new Error "Unknown node format: #{nestedNode[<%- SCHEMA.format %>]}"
				# nested value
				# if nested= node[<%- SCHEMA.nested %>]
				# 	nodes.push nested, level+1
				# else
				# 	result.push "(#{node[<%-SCHEMA.type %>].name})"
		return result.join ''
# node[<%-SCHEMA.nested %>]