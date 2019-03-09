###*
 * List/object attribute check
 * This code is part of instance-from.coffee
 * @param {number} i - schema attribute index
 * @param {string or number} attrName attribute name
 * @param {mixed} attrObj - attribute or list item value
###

# check / convert
unless schema[i + <%= SCHEMA.attrCheck %>] attrObj
	attrObj = schema[i + <%= SCHEMA.attrConvert %>] attrObj # convert

# exec assertions: [assertionFx, optionalMessage, ...]
if asserts = schema[i + <%= SCHEMA.attrAsserts %>]
	for assertFx in asserts
		assertFx attrObj, obj, attrName

# Type level assertions
if (asserts = schema[i + <%= SCHEMA.attrPropertyAsserts %>])
	assertsI= 0
	assertsLen= asserts.length # [assertName, assertParam, assertFx]
	while assertsI < assertsLen
		asserts[assertsI+1] attrObj, asserts[assertsI+2], obj, attrName
		assertsI += 3 # [assertName, assertParam, assertFx]

# apply pipes
<% if(!isValidateOnly){ %>
if pipes = schema[i + <%= SCHEMA.attrPipe %>]
	for v in pipes
		attrObj = v.call obj, attrObj, attrName
<% } %>

# save modifitations
obj[attrName] = attrObj