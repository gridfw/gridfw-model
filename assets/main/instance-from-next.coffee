
<%
var schemaIdx = isList ? SCHEMA.listSchema: 'i + '+ SCHEMA.attrSchema
var schemaRef = isList ? SCHEMA.listRef: 'i + '+ SCHEMA.attrRef
var schemaSnapshot = isList ? SCHEMA.listSnapshot: 'i + '+ SCHEMA.attrSnapshot

%>
if typeof attrObj is 'object' and attrObj
	nxSchema = schema[<%= schemaIdx %>]
	unless nxSchema
		# reference
		if nxRef = schema[<%= schemaRef %>]
			nxMd = model.all[nxRef]
			throw "Reference resolve fails: #{nxRef}" unless nxMd
			nxSchema= nxMd[SCHEMA]
		# snapshot
		else if nxRef= schema[<%= schemaSnapshot %>]
			nxSchema = model.snapshots[nxRef]
			throw "Snapshot resolve fails: #{nxRef}" unless nxSchema
		# fatal error
		else
			throw new Error 'No reference or snapshot set!'
		# future fast access
		schema[<%= schemaIdx %>]= nxSchema
	seekQueu.push attrObj, nxSchema, (path.concat attrName)