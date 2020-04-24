# gridfw-model
- Model for javascript
- Data validator


## Create new Model:
```javascript
const Model= require('gridfw-model');

// Create new Model
ModelEngine= new Model();

// Define new Model
ModelEngine.define('modelName',{schema});

// Example
ModelEngine.define('User',{
	firstName:	String
	lastName:	String
	age:		Number
	hobbies:	[String] // list of strings

	// List of Objects
	skills: [{
		name: String,
		level: Number
	}]
});

// Advanced example
ModelEngine.define('User',{
	name: Model.String.max(300).min(2)
	skills: Model.List({
		name: Model.String.max(20)
		level: Model.Int.min(0).max(100)
	})
});
```

## Override existing model
Add or modify properties
```javascript
ModelEngine.override('modelName', {schema});
```

## Extending a model
```javascript
ModelEngine.extends('modelName', 'parentModelName' {schema});

// @Example
MemberClass= ModelEngine.extends('Member', 'User', {schema});
```

## Attribute Types:

### Numbers:
```javascript
// Supported types
Number
Model.Number
Model.Int // Any integer
Model.Unsigned // Insigned integer, equivalent to Model.Int.min(0)
Model.Hex	// String as hex Integer
BigInt
Model.BigInt

// SUPPORTED ASSERTS
.lt(n, optionalErrorMessage)		// Less then
.lte(n, optionalErrorMessage)		// Less then or equals
.gt(n, optionalErrorMessage)		// Greater then
.gte(n, optionalErrorMessage)		// Greater then or equals

.min(n, optionalErrorMessage)		// alias to: gte()
.max(n, optionalErrorMessage)		// alias to: lte()
```

### Strings
```javascript
// Supported types
String			// Equivalent to Model.String
Model.String	// is: Model.String.max(3000), add custom "max" value as needed.
Model.Text		// Encode any XSS caracters
Model.HTML		// Remove any XSS and images from HTML code
Model.HTMLImgs	// Remove any XSS, keep images
Model.Email		// Valide email address
Model.Password	// equivalent to Model.String.min(6).max(100)

// SUPPORTED ASSERTS
.lt(n, optionalErrorMessage)		// String length less then
.lte(n, optionalErrorMessage)		// String length less then or equals
.gt(n, optionalErrorMessage)		// String length greater then
.gte(n, optionalErrorMessage)		// String length greater then or equals

.min(n, optionalErrorMessage)		// alias to: gte()
.max(n, optionalErrorMessage)		// alias to: lte()

.length(n, optionalErrorMessage)	// Fixed string length
.match(/regex/, optionalErrorMessage)	// Use RegExp to check string value
```

### Booleans
```javascript
// Supported types
Boolean
Model.Boolean
```

### Date
```javascript
// Supported types
Date
Model.Date
```

### URL
```javascript
// Supported types
URL
Model.URL
Model.ImageURL	// Valide image URL or Data, equivalent to Model.URL.max()
Model.DataURL	// Valide file URL or Data

// SUPPORTED ASSERTS
.lt(n, optionalErrorMessage)		// String length less then
.lte(n, optionalErrorMessage)		// String length less then or equals
.gt(n, optionalErrorMessage)		// String length greater then
.gte(n, optionalErrorMessage)		// String length greater then or equals

.min(n, optionalErrorMessage)		// alias to: gte()
.max(n, optionalErrorMessage)		// alias to: lte()

.length(n, optionalErrorMessage)	// Fixed string length
.match(/regex/, optionalErrorMessage)	// Use RegExp to check URL value
.pathMatches(/regex/, optionalErrorMessage)	// Use RegExp to check URL pathname value
```

### ObjectId
```javascript
// Supported types
Model.ObjectId
```

## Attribute Directives
### Required, Optional
```javascript
/** REQUIRED, OPTIONAL */
attr: Model.required	// Set attribute as required
attr: Model.optional	// @default, set attribute as optional

/** FREEZE, EXTENSIBLE */
attr: Model.freeze	// Accept only declared attributes, remove any extra attribute
attr: Model.extensible	// @default, accept additional attributes

/** NULL, NOTNULL */
attr: Model.null		// @default, The attribute could be null
attr: Model.notNull	// The attribute could not be null

/** JSON */
attr: Model.enableJSON	// @default, Serailize and parse from JSON
attr: Model.ignoreJSON	// Ignore parsing and serializing from and to JSON
attr: Model.ignoreJsonParse	// Ignore parsed value from JSON
attr: Model.ignoreJsonStringify	// Ignore when serializing to JSON
attr: Model.toJSON(function(data, key, parentObject){return data}); // Replacer to use when serializing to JSON
attr: Model.fromJSON(function(data, key, parentObject){return data}), // Replacer to use when parsing from JSON

/** DataBase */
attr: Model.virtual		// Ignore value when sending to DB
attr: Model.transient		// Alias to "virtual"
attr: Model.persist		// @default, send value to DB
attr: Model.toDB(function(data, key, parentObject){return data}); // Replacer to use when sending data to DB
attr: Model.fromDB(function(data, key, parentObject){return data}), // Replacer to use when getting data from DB

/** Getters/Setters */
attr: Model.default(value)	// set a default value to the attribute when parsing from JSON
attr: Model.default(function(key, currentObject){return 'xxx'}); // Call this function when parsing from JSON to generate a value
attr: Model.default(Date.now)	// Set to date.now() when no value is set when parsing from JSON

attr: Model.getter(function(){});		// define a getter on this attribute
attr: Model.getOnce(function(){});	// Call this function once when value is missing and save the value to the object
attr: Model.setter(function(value){this.xx=value;})	// Define a setter on this attribute

/** METHODS */
attr: function(args){}; // Define a method on that attribute
attr: Model.method(function(args){}); // define a method on that attribute

/** Asserts */
attr: Model.assert(true)		// assert value is a static value
attr: Model.assert('value')		// assert value is a static value
attr: Model.assert(function(data, _, key, parentObject){return true}) // add an assert check
attr: Model.assert({ lt: 15, gte: 5 }); // predefined asserts

attr: Model.length(15, 'optional error message')	// Assert list, map, string or URL.href length
attr: Model.lt(15, 'optional error message')		// Assert list, map, string or URL must less than 15
attr: Model.lte(15, 'optional error message')		// Assert list, map, string or URL must less than or equals 15
attr: Model.gt(15, 'optional error message')		// Assert list, map, string or URL must greater than 15
attr: Model.gte(15, 'optional error message')		// Assert list, map, string or URL must greater than or equals 15
attr: Model.min(15, 'optional message')				// Alias to Model.gte
attr: Model.max(15, 'optional message')				// Alias to Model.lte
attr: Model.match(/regex/, 'optional error message')// Assert String or URL.href matches this RegExp
attr: Model.pathMatches(/regex/, 'optional error message')// Assert URL.pathname matches this RegExp

attr: Model.pipe(function(data, key, parentObject){return data})		// add a pipeline function to be called when parsing from JSON
attr: Model.pipeOnce(function(data, key, parentObject){return data})	// add this function to pipeline only once. Will be called once when parsing from JSON

/** Changing prototype */
attr: Model.list(...).proto({ method: fx}) // Add prototype functions to this list, map or object
```

## Adding sub objects

```javascript
attr:{
	subAttr:	'xxx'
	subAttr2:	'xxx'
	subAttr3: {
		subAttr31:	'value'
		subAttr32:	'value'
	}
}

// OR
attr: Model.value({
	subAttr:	'xxx'
	subAttr2:	'xxx'
	subAttr3: Model.value({
		subAttr31:	'value'
		subAttr32:	'value'
	})
})

// Useful to add more control
attr: Model.required.freeze.value({schema})
```

## Adding sub lists

```javascript
attr: [Number]		// List of numbers
attr: [Model.Int]	// List of integers

// List of objects with schema
attr: [{
	subAttr:	'xxx'
	subAttr2:	'xxx'
}]

// OR
attr: Model.list(Number)
attr: Model.list({schema})

// Useful to add more control
attr: Model.list(Number).gte(7).lte(50)
```


## Adding Maps
Maps enables us to add sub objects with an unknown schema, but has specific rules

```javascript
attr: Model.map(String, String)	// map of String as key and String as value
attr: Model.lt(75).map(Model.String.lt(20), Number)	// map with String less than 20 as a key, and Number values. the keys count must be less than 75
```

## JSON

### Serializing to JSON
```javascript
// Just call JSON.stringify to serialize your object
JSON.stringify(myObject);
```

### Parsing from JSON

```javascript
// First parse JSON as usual
myObject= JSON.parse('{...}');

// If you just need to control DATA: call this (all methods do data conversions and removes any extra value if needed)
MyClass= Model.get('myClass');
MyClass.assert(myObject); // Removes any extra value and do all conversions and controls. Throws error when found or assertion failed
{warnings, errors}= MyClass.scan(myObject)	// do a full check for the object to find errors and warnings

// If you need to convert object to be of type "MyClass" so you could use defined methods and serializers (toJSON, toDB)
MyClass.convert(myObject)	// @throws error when found or assertion failed
{warnings, errors}= MyClass.checkAndConvert(myObject)// do check and convert, returns found warnings and errors
```

## DB

### Sending to DB
- If you use mongoDB, just call mongoDB methods as usual
- If you use an other DB engine, call first "myPreparedObject= myObject.exportDB()" and save "myPreparedObject" instead

### Loading from DB
- If you use a specifique pluging to "Gridfw-Model" to manipulate the DB (like "Gridfw-MongoDB"), @see it's documentation
- Otherwise, when receiving data from DB, use this methods: MyClass.fromDB(myObject);

