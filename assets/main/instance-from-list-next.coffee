


if typeof attrObj is 'object' and attrObj
	nxSchema = schema[i+<%= SCHEMA.listSchema %>]
	unless nxSchema
		# reference
		if nxRef = schema[i+<%= SCHEMA.listRef %>]
			nxMd = model.all[nxRef]
			throw "Reference resolve fails: #{ref}"
			nxSchema= schema[i+<%= SCHEMA.listSchema %>]= nxMd[SCHEMA]
	seekQueu.push attrObj, nxSchema, (path.concat j)