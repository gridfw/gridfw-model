/* for performance porpose, we use schema as array
This template will help to simulate object format to symplify code
*/

SCHEMA = {
	proto: Object.create null, // store prototype of this object
};

// convert to Array
SCHEMA_ARR
for(k in SCHEMA)
	SCHEMA[k] = SCHEMA_ARR.push(SCHEMA[k]) - 1

// index where attributes starts
SCHEMA.sub = SCHEMA_ARR.length - 1