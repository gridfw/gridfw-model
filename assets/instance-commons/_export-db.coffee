###*
 * Export data to DATABASE
###
exportDB: ->
	# result
	result= {}
	# prepare non recursive
	nodes= [{_root: this}, result]
	seekIndex= 0
	maxLoop= @constructor.Model._maxLoop or DEFAULT_MAX_LOOP # Maximum seeks
	while seekIndex < nodes.length
		# Prevent infinit loops
		throw new Error "Max loop exceeded: #{maxLoop}" if seekIndex >= maxLoop
		# Load data
		node=		nodes[seekIndex++]
		nodeClone=	nodes[seekIndex++]
		# Clone
		<% function _exportDBClone(){ %>
				if (typeof el is 'object') and el?
					# use toDB function
					el= el.toDB() if typeof el.toDB is 'function'
					# make clone
					if (typeof el is 'object') and el?
						clone= if _isArray el then [] else {}
					else
						clone= el
				else
					clone= el
		<% } %>
		# Copy
		if _isArray node
			for el in node
				<% _exportDBClone() %>
				nodes.push el, clone if typeof clone is 'object' and clone?
				nodeClone.push clone
		else
			for k in _keys node
				el= node[k]
				<% _exportDBClone() %>
				if clone?
					nodeClone[k]= clone
					nodes.push el, clone if typeof clone is 'object'
	# Return
	return result._root