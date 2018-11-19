/* for performance porpose, we use schema as array
This template will help to simulate object format to symplify code
*/

SCHEMA = {
	proto: null, //Object.create null, // store prototype of this object
	check: null, // check all inner elements with this
};

// convert to Array
SCHEMA_ARR
for(k in SCHEMA)
	SCHEMA[k] = SCHEMA_ARR.push(SCHEMA[k]) - 1

// index where attributes starts
SCHEMA.sub = SCHEMA_ARR.length - 1

// attribute descriptors:
// 		attrName
// 		attrCheck
// 		attrConvert
// 		attrSubSchema (when plain object or array)
// 		attrValidate