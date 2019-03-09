/* for performance porpose, we use schema as array
This template will help to simulate object format to symplify code

-- nested objects
	- schemaType: 1
	- proto: {}
	- ignoreJSON: [...]
	- required: [...]
	- virtual: [...]
	- extensible: true
	- toJSON: [...]
	- toDB: [...]
-- nested list
	- schemaType: 2
	- proto: {}
	- listType: list item type
	- listCheck: fx (check all attributes)
	- listConvert: fx (convert illegal attributes)
	- listSchema: schema # sub items schema
*/

var nestedObjSchema = [
	'schemaType',	// is nested list or nested object
	'proto',		// schema prototype
	'extensible',	// if the object could contains attributes other then specified ones
	'ignoreJSON',	// list of attributes to be ignored when serializing as JSON
	'virtual',		// virtual attributes

	'toJSON',		// [attr, toJSONFx.call(parentObj, data, attr), ...] convert attributes
	'toDB'			// [attr, toDBFx.call(parentObj, data, attr), ...] convert attributes
];
var nestedListSchema = [
	'schemaType',	// is nested list or nested object
	'proto',		// schema prototype
	'listType',		// list item type
	'listCheck',	// fx: check list items basid on some type
	'listConvert',	// fx: list item type convertion
	'listSchema',	// list items schema
	'listRef',		// reference
];
// attribute descriptors
var schemaAttrDescrptr =[
	'attrName',		// name of the attribute (keep in top!)
	'attrType',		// type of the attribute
	'attrCheck',	// check attribute type
	'attrConvert',	// convert attribute type
	'attrNull', // do this attribute can be null or undefined. Remove it otherwise when null or undefined.
	'attrAsserts',	// list of assertion functions
	'attrPropertyAsserts',	// predefined asserts: ['assertName', assertValue, assertFx, ...] exple: ['min', 4, minFx, 'max', 521, maxFx]
	'attrPipe',		// list of pipe functions
	'attrSchema',	// sub-schema
	'attrRef',		// reference

	'attrRequired',
	'attrIgnoreJSONParsing',

	// debug purpose attributes
	'attrJSONIgnore',
	'attrVirtual',
	'attrExtensible'
];

var SCHEMA_DESCRIPTOR_K= [
	'type',
	'check',
	'convert',
	'clear', // clear previous configuration
	'null',
	'required',
	'extensible',
	// JSON
	'jsonIgnore',
	'toJSON',
	// Database
	'virtual',
	'toDB',
	// Getter/Setter, define prototype property
	'define',
	// assert
	'asserts', // asserts queue
	'assertPredefined',// predefined asserts
	'assertions',
	// pipe
	'pipe',
	'pipeOnce',
	// reference
	'ref',
	// nested 15
	'nested',
	'listProto' // list prototype

];


// create schema info
var SCHEMA = Object.create(null);
for(var len = nestedObjSchema.length, i= 0; i< len; ++i){
	k = nestedObjSchema[i];
	SCHEMA[k] = i;
}
for(var len = nestedListSchema.length, i= 0; i< len; ++i){
	k = nestedListSchema[i];
	SCHEMA[k] = i;
}
for(var len = schemaAttrDescrptr.length, i= 0; i< len; ++i){
	k = schemaAttrDescrptr[i];
	SCHEMA[k] = i;
}


// index where attributes starts
SCHEMA.sub = Math.max(nestedObjSchema.length, nestedListSchema.length);
SCHEMA.attrPropertyCount = schemaAttrDescrptr.length; // attribute properties count
SCHEMA.OBJECT = 1;
SCHEMA.LIST = 2;

// schema descriptor
var SCHEMA_DESC= Object.create(null);
for(var len = SCHEMA_DESCRIPTOR_K.length, i= 0; i< len; ++i){
	k = SCHEMA_DESCRIPTOR_K[i];
	SCHEMA_DESC[k] = i;
}