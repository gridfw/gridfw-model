

if typeof attrObj is 'object' and attrObj and not (SCHEMA of attrObj) # prevent circles
	nxSchema = schema[i + <%= SCHEMA.attrSchema %>]
	unless nxSchema
		# reference
		if nxRef = schema[i + <%= SCHEMA.attrRef %>]
			nxMd = model.all[nxRef]
			throw "Reference resolve fails: #{nxRef}" unless nxMd
			nxSchema= nxMd[SCHEMA]
		# fatal error
		else
			throw new Error 'No reference set!'
		# future fast access
		schema[i + <%= SCHEMA.attrSchema %>]= nxSchema
	seekQueu.push attrObj, nxSchema, (path.concat attrName)