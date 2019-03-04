

if typeof attrObj is 'object' and attrObj
	nxSchema = schema[i+<%= SCHEMA.attrSchema %>]
	unless nxSchema
		# reference
		if nxRef = schema[i+<%= SCHEMA.attrRef %>]
			nxMd = model.all[nxRef]
			throw "Reference resolve fails: #{ref}"
			nxSchema = schema[i+<%= SCHEMA.attrSchema %>]= nxMd[SCHEMA]
	seekQueu.push attrObj, nxSchema, (path.concat attrName)