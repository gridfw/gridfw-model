###*
 * This is only a documentation, not an inner code
 * This doc describes the internal format of the schema
 * Each object or sub-object is linked to a schema
###
schema:[
	proto: {} #link to this level prototype
	jsonIgnore: [] # when exists, contains list of attributes to be ignored when serializing as JSON
	dbIgnore: [] # when exists, contains list of attributes to be ignored when sending to DB (transient properties)
	extensible: true|false # if the object could contains none listed attributes
	
	# sub schema
	attr,
	checkFx,
	convertFx,
	SUB_SCHEMA,
	# ...

]
