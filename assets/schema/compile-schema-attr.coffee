###*
 * Map schema attributes
 * This code is part of compile-schema.coffee
 * @param {Mixed} attrV - attribute value
 * @param {number} attrI - attribute index
###

# check not Model
throw "Illegal use of Model" if attrV is Model

# attr name
schema[attrI] = attrN
# default value of "typeof" is "field"
schema[attrI+ <%= SCHEMA.attrTypeOf %>]= <%= attrTypeOf.field %>

# get attribute descriptor
attrDescriptor= attrV[DESCRIPTOR]
unless attrDescriptor
	attrV= Model.value attrV
	attrDescriptor= attrV[DESCRIPTOR]

# descriptor check
for fx in _descriptorChecks
	fx attrDescriptor

# compile descriptor
# compile: index, (value, attr, schema, proto, attrIndex, descriptor)
descrpI = 0
descrpLen= _descriptorCompilers.length
proto= schema[<%= SCHEMA.proto %>]
while descrpI < descrpLen
	idx= _descriptorCompilers[descrpI++]
	fx= _descriptorCompilers[descrpI++]
	vl= attrDescriptor[idx]
	unless vl is undefined
		fx vl, attrN, schema, proto, attrI, attrDescriptor

# nested
if ref= attrDescriptor[<%= SCHEMA_DESC.nested %>]
	# Reference
	if attrDescriptor[<%= SCHEMA_DESC.ref %>]
		# do nothing
	# nested object or array
	else
		seekQueue.push schema[attrI + <%= SCHEMA.attrSchema %>], attrV, path.concat attrN