/**
 * Template to generate default descriptor Array
 */
AttrDescriptor = {
	type: null, // reference to current type, default to Mexed
	// check: null, // check function
	// convert: null, // convert value when check fails

	value: null, // subschema

	// flags
	required: false, // if the attribute is required
	extensible: true, // when the value is an Object, if it is extensible

	/**
	 * JSON ignore
	 * 	0: Enable JSON 
	 * 	1: Ignore stringify
	 * 	2: Ignore parse
	 * 	3: Ignore all
	 */
	jsonIgnore: 0,

	/**
	 * DB persistance
	 */
	virtual: false, // when true, do not send to DB

	// default value
	default: null,
	defaultFx: null, // default value fx: (parent)-> value

	// asserts
	assert: {}, // assert object
	};

// create table
attrDescTable = []
for( k in AttrDescriptor )
	AttrDescriptor[k] = attrDescTable.push(AttrDescriptor[k]) - 1