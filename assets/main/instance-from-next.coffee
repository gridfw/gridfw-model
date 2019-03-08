
<%
var schemaIdx = isList ? SCHEMA.listSchema : 'i + '+ SCHEMA.attrSchema;
var schemaRef = isList ? SCHEMA.listRef : 'i + '+ SCHEMA.attrRef;
%>
if typeof attrObj is 'object' and attrObj
	nxSchema = schema[<%= schemaIdx %>]
	unless nxSchema
		# reference
		if nxRef = schema[<%= schemaRef %>]
			nxMd = model.all[nxRef]
			throw "Reference resolve fails: #{nxRef}" unless nxMd
			nxSchema= nxMd[SCHEMA]
		# fatal error
		else
			throw new Error 'No reference set!'
		# future fast access
		schema[<%= schemaIdx %>]= nxSchema
	seekQueu.push attrObj, nxSchema, (path.concat attrName)