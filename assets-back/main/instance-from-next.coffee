

if typeof attrObj is 'object' and attrObj and not (SCHEMA of attrObj) # prevent circles
	nxSchema = schema[i + <%= SCHEMA.attrSchema %>]
	if nxSchema
		seekQueu.push attrObj, nxSchema, (path.concat attrName)
	else
		# reference
		if nxRef = schema[i + <%= SCHEMA.attrRef %>]
			nxMd = model.all[nxRef]
			throw "Reference resolve fails: #{nxRef}" unless nxMd
			nxSchema= nxMd[SCHEMA]
			# future fast access
			schema[i + <%= SCHEMA.attrSchema %>]= nxSchema
			# next
			seekQueu.push attrObj, nxSchema, (path.concat attrName)
		# fatal error
		# else
		# 	throw new Error 'No reference set!'
		