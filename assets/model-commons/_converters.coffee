###*
 * Remove undefined and null values from object
###
<% function _convertersRmUndefined(){ %>
		node= rootInstance._ROOT
		if typeof node is 'object' and node?
			nodes.length= 0
			nodes.push rootInstance, '_ROOT', node # non recursive queue
			seekIndex= 0
			while seekIndex < nodes.length
				throw new Error "Max loop exceeded: #{maxLoop}" if seekIndex >= maxLoop
				# Load data
				parentNode=	nodes[seekIndex++]
				nodeAttr=	nodes[seekIndex++]
				node=		nodes[seekIndex++]
				# Array
				if _isArray node
					for v,i in node
						nodes.push node, i, v if typeof v is 'object' and v?
				# Object
				else
					# check if some element is null
					hasNull= no
					for k,v of node
						unless v?
							hasNull= yes
							break
					# if has null
					if hasNull
						old= node
						node= parentNode[nodeAttr]= {}
						# Copy non null values
						for k,v of old
							if v?
								node[k]= v
								nodes.push node, k, v if typeof v is 'object'
<% } %>
###*
 * convert instances
###
<%
function parseInstance(fxName, isJSON, isAssert, isAsync){
	isDB= !isJSON
	isScan= fxName==='scan'
	isConvertDB= fxName==='convertDB'
	isFromJsonToDb= fxName==='fromJsonToDb'
	awaitWhenAsync= isAsync? 'await ':''
%>
	# if is scan
	<% if(isScan){ %>
	scanErrors= []
	<% } %>
	try
		nodePath= []
		# Checks
		throw 'Expected schema' unless schema= @[SCHEMA_SYMB]
		throw 'Giving instance is null' unless instance
		# result
		rootInstance= '_ROOT': instance
		# prepare non recursive seeking
		nodes= [rootInstance, schema, nodePath] # non recursive queue
		maxLoop= @_maxLoop # Maximum seeks
		seekIndex= 0
		while seekIndex < nodes.length
			try
				# Prevent infinit loops
				throw "Max loop exceeded: #{maxLoop}" if seekIndex >= maxLoop
				# Load data
				node			= nodes[seekIndex++]
				nodeSchema		= nodes[seekIndex++]
				nodePath		= nodes[seekIndex++]
				# Load infos
				nodeFormat				= nodeSchema[<%-SCHEMA.format %>]
				nodePrototype			= nodeSchema[<%-SCHEMA.prototype %>]
				jsonIgnoreAttributes	= nodeSchema[<%-SCHEMA.ignoreJsonAttrs %>]
				virtualAttributes		= nodeSchema[<%-SCHEMA.virtuals %>]
				toJSON_callbacks		= nodeSchema[<%-SCHEMA.toJSON %>]
				toDB_callbacks			= nodeSchema[<%-SCHEMA.toDB %>]
				# switch
				switch nodeFormat
					# Compile attributes
					<% function _compileAttributes(){ %>
							attrPath=	nodePath.concat attrName
							try
								# ignore if ignoreJsonParse
								<% if(isFromJsonToDb) { %>
								if attrFlags&<%-SCHEMA.VIRTUAL %>
									node[attrName]= undefined if node[attrName]?
									continue
								else if attrFlags&<%-SCHEMA.ignoreJsonParse %>
									attrValue= undefined
								else
									attrValue= node[attrName]
								<% }else if(isJSON) { %>
								attrValue= if attrFlags&<%-SCHEMA.ignoreJsonParse %> then undefined else node[attrName]
								<% }else{ %>
								attrValue= node[attrName]
								<% } %>
								# check is null
								unless attrValue?
									<% if(isJSON) { %>
									# Has default value
									if (defaultValue= nodeSchema[attrIndex+<%-SCHEMA_ATTR.default %>])?
										if typeof defaultValue is 'function'
											attrValue= <%-awaitWhenAsync %>defaultValue attrName, node
										else
											attrValue= defaultValue
										node[attrName]= attrValue
										continue unless attrValue
									# attr must be not null
									else if attrFlags&<%-SCHEMA.NOT_NULL %>
										throw "Missing: #{attrName}"
									else
										node[attrName]= attrValue
										continue
									<% }else{ %>
									continue
									<% } %>
								# convert value			---------------------------------------------------
								attrValue= nodeSchema[attrIndex+<%-SCHEMA_ATTR.convert %>] attrValue, attrName, node
								# Create new instance if nested Object or List			-------------------
								<% if(!isAssert){ %>
								if nestedSchema= nodeSchema[attrIndex+<%-SCHEMA_ATTR.nested %>]
									switch nestedSchema[<%-SCHEMA.format %>]
										# OBJECT	<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
										when <%-SCHEMA.OBJECT %>
											# CONVERT EXISTING OBJECT
											<% if(isConvertDB){ %>
											_defineProperties attrValue, _getOwnPropertyDescriptors nestedSchema[<%-SCHEMA.prototype %>]
											
											# CREATE NEW PROTOTYPED OBJECT
											<% } else { %>
											oldAttrValue= attrValue
											# Create new object with prototype
											<% if(isFromJsonToDb){ %>
											attrValue= {}
											<% }else{ %>
											attrValue= _create nestedSchema[<%-SCHEMA.prototype %>]
											<% } %>
											# Add declared attributes
											nestedI= <%-SCHEMA.length %>
											len= nestedSchema.length
											while nestedI<len
												nestedAttrName= nestedSchema[nestedI+<%-SCHEMA_ATTR.name %>]
												attrValue[nestedAttrName]= oldAttrValue[nestedAttrName]
												nestedI+= <%-SCHEMA_ATTR.length %>
											# Add additional attributes attributes
											unless attrFlags&<%-SCHEMA.FREEZE %>
												_assign attrValue, oldAttrValue
											<% } %>
										# LIST	<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
										when <%-SCHEMA.LIST %>
											# CONVERT EXISTING LIST
											<% if(isConvertDB){ %>
											_defineProperties attrValue, _getOwnPropertyDescriptors nestedSchema[<%-SCHEMA.prototype %>]
											
											# CREATE NEW PROTOTYPED LIST
											<% } else { %>
											oldAttrValue= attrValue
											<% if(isFromJsonToDb){ %>
											attrValue= []
											<% }else{ %>
											attrValue= new nestedSchema[<%-SCHEMA.prototype %>]() # create new Array from class
											<% } %>
											# copy content
											attrValue.push el for el in oldAttrValue
											<% } %>
										# MAP	<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
										when <%-SCHEMA.MAP %>
											# CONVERT EXISTING LIST
											<% if(isConvertDB){ %>
											_defineProperties attrValue, _getOwnPropertyDescriptors nestedSchema[<%-SCHEMA.prototype %>]
											
											# CREATE NEW PROTOTYPED LIST
											<% } else { %>
											oldAttrValue= attrValue
											# Create new object with prototype
											<% if(isFromJsonToDb){ %>
											attrValue= {}
											<% }else{ %>
											attrValue= _create nestedSchema[<%-SCHEMA.prototype %>]
											<% } %>
											# Copy values
											_assign attrValue, oldAttrValue
											<% } %>
									# push node [instance, schema, path]
									nodes.push attrValue, nestedSchema, attrPath
								<% } %>
								# FROM TRUSTED SOURCE	---------------------------------------------------
								<%  if(isDB) { %>
								attrValue= <%-awaitWhenAsync %>cb attrValue, attrName, node if cb= nodeSchema[attrIndex+<%-SCHEMA_ATTR.fromDB %>]
								# FROM UNTRUSTED SOURCE	---------------------------------------------------
								<% }else{ %>
								# Asserts
								assertsArr= nodeSchema[attrIndex+<%-SCHEMA_ATTR.asserts %>]
								assertsI= 0
								assertsLen= assertsArr.length
								while assertsI<assertsLen # [assertKey, assertParam, assertCompare(data, param, parentObj), errMsg]
									unless <%-awaitWhenAsync %>assertsArr[assertsI+2] attrValue, assertsArr[assertsI+1], attrName, node, attrPath
										throw assertsArr[assertsI+3] or "Assertion failed: #{assertsArr[assertsI]} #{assertsArr[assertsI+1]}"
									assertsI+= 4
								# When converting JSON or any untrusted source
								<%  if(isJSON) { %>
								# fromJSON
								attrValue= <%-awaitWhenAsync %>cb attrValue, attrName, node if cb= nodeSchema[attrIndex+<%-SCHEMA_ATTR.fromJSON %>]
								# Call pipes
								for cb in nodeSchema[attrIndex+<%-SCHEMA_ATTR.pipe %>]
									attrValue= <%-awaitWhenAsync %>cb attrValue, attrName, node
								<% }} %>
								# if toDB, call fxes
								<%  if(isFromJsonToDb) { %>
								if cb= nodeSchema[attrIndex+<%-SCHEMA_ATTR.toDB %>]
									attrValue= cb.call node, attrValue, attrName
								<% } %>
							# convert
							catch err
								attrValue= null
								<% if(isScan){ %>
								scanErrors.push {
									error:	err
									path:	attrPath
								}
								<% }else{ %>
								err= "#{err}\nAt: #{attrPath.join '.'}" if typeof err is 'string'
								throw err
								<% } %>
							# Save value
							node[attrName]= attrValue
					<% } %>
					# Object, ROOT
					when <%-SCHEMA.OBJECT %>, <%-SCHEMA.ROOT %>
						loopIndex=	<%-SCHEMA.length %>
						attrLen=	nodeSchema.length
						while loopIndex<attrLen
							# To prevent future errors with "continue" statements
							attrIndex= loopIndex
							loopIndex+= <%-SCHEMA_ATTR.length %>
							# data
							attrName=	nodeSchema[attrIndex+<%-SCHEMA_ATTR.name %>]
							attrFlags=	nodeSchema[attrIndex+<%-SCHEMA_ATTR.flags %>]
							# Compile attribute
							<% _compileAttributes() %>
					# List
					when <%-SCHEMA.LIST %>
						attrIndex=	<%-SCHEMA.length %>
						attrFlags=	nodeSchema[<%-SCHEMA.length + SCHEMA_ATTR.flags %>]
						listLen= node.length
						loopIndex= 0
						while loopIndex<listLen
							attrName= loopIndex
							++loopIndex
							# Compile attribute
							<% _compileAttributes() %>
					# MAP
					when <%-SCHEMA.MAP %>
						attrIndex=	<%-SCHEMA.length+SCHEMA_ATTR.length %>
						for mapKey of node
							# Check key		--------------------------------------------------------------
							<%  if(isJSON) { %>
							# Assert type
							mapKey2= nodeSchema[<%-SCHEMA.length+SCHEMA_ATTR.convert %>] mapKey
							throw 'Illegal key' unless mapKey2 is mapKey
							# Asserts
							assertsArr= nodeSchema[<%-SCHEMA.length+SCHEMA_ATTR.asserts %>]
							assertsI= 0
							assertsLen= assertsArr.length
							while assertsI<assertsLen # [assertKey, assertParam, assertCompare(data, param, parentObj), errMsg]
								unless <%-awaitWhenAsync %>assertsArr[assertsI+2] attrValue, assertsArr[assertsI+1], attrName, node
									throw assertsArr[assertsI+3] or "Assertion failed>> #{assertsArr[assertsI+1]} #{assertsArr[assertsI+2]}"
								assertsI+= 4
							<% } %>
							# Check value	--------------------------------------------------------------
							attrName=	mapKey
							attrFlags=	nodeSchema[<%-SCHEMA.length+SCHEMA_ATTR.length+SCHEMA_ATTR.flags %>]
							# Compile attribute
							<% _compileAttributes() %>
					# Link to other type
					when <%-SCHEMA.LINK %>
						throw 'Missing linked schema' unless nestedSchema= nodeSchema[<%-SCHEMA.linkedTo %>]
						# push node [instance, schema, path]
						nodes.push node, nestedSchema, attrPath
					else
						throw "Enexpected object format: #{nodeFormat}"
			catch err
				<% if(isScan){ %>
				scanErrors.push {
					error:	err
					path:	nodePath
				}
				<% }else{ %>
				err= "#{err}\nAt: #{nodePath.join '.'}" if typeof err is 'string'
				throw err
				<% } %>
		# Remove undefined and null values if is "fromJsonToDb"
		<% if(isFromJsonToDb) _convertersRmUndefined(); %>
	catch err
		<% if(isScan){ %>
		scanErrors.push {
			error:	err
			path:	nodePath
		}
		<% }else{ %>
		err= "<%-fxName %>>> #{err}\nAt: #{nodePath.join '.'}" if typeof err is 'string'
		throw err
		<% } %>
	# Return
	<% if(fxName==='assert') { %>
	return true
	<% }else if(isScan){ %>
	return
		instance:	rootInstance._ROOT
		errors:		scanErrors
		hasErrors:	!!scanErrors.length
	<% }else{ %>
	return rootInstance._ROOT
	<% } %>
<% } %>
###*
 * Convert trusted object
 * @return {Object} converted instance
###
# fxName, isJSON, isAssert, isAsync
fromDB: (instance)->
	<% parseInstance('fromDB', false, false, false) %>
fromDBAsync: (instance)->
	<% parseInstance('fromDB', false, false, true) %>

###*
 * Add required methods and converters to the same instances
 * but the instance still not of type "ModelClass"
 * Could be fast then "fromDB"
 * @return {Mixed} the same instance
###
convertDB: (instance)->
	<% parseInstance('convertDB', false, false, false) %>
convertDBAsync: (instance)->
	<% parseInstance('convertDB', false, false, true) %>
###*
 * Convert Intrusted object
 * @return {Mixed} converted instance
###
fromJSON: (instance)->
	<% parseInstance('fromJSON', true, false, false) %>
fromJSONAsync: (instance)->
	<% parseInstance('fromJSON', true, false, true) %>

###*
 * From JSON to Database
###
fromJsonToDb: (instance)->
	<% parseInstance('fromJsonToDb', true, false, false) %>
fromJsonToDbAsync: (instance)->
	<% parseInstance('fromJsonToDb', true, false, true) %>

###*
 * Apply asserts and converters without converting object type
 * (used instead of "fromJSON")
 * @throws {Error} If found error
###
assert: (instance)->
	<% parseInstance('assert', false, true, false) %>
assertAsync: (instance)->
	<% parseInstance('assert', false, true, true) %>
###*
 * Full Check of instrusted objects
 * @return {Object} {errors:[], warnings: [], instance}
###
scan: (instance)->
	<% parseInstance('scan', false, true, false) %>
scanAsync: (instance)->
	<% parseInstance('scan', false, true, true) %>