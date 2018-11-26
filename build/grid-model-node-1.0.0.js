var indexOf = [].indexOf;

(function() {
  /**
   * Model regestry
   */
  /**
   * This Map contains all supported types
   */
  /**

   * convert Set to Array

   */
  /**

   * Commun array prototype

   */
  /**

   * Check is number

   */
  /**
   * Compile nested array
   */
  /**
   * Compile nested object
   */
  /* compile schema */
  /* wrapper */
  /**
   * Fast object convertion
   * from DB or any trusted source
   * No validation will be performed
   * Do not use recursivity for performace purpos and 
   * to avoid possible stack overflow
   */
  /**
   * Convert instance to Model type
   * used when data is from untrusted source
   * will do validation and any required clean
   * example: JSON from client
   */
  /* Common plain object prototype */
  /* JSON cleaner */
  var DATA_URL_MEX_LENGTH, DESCRIPTOR, EMAIL_CHECK, HEX_CHECK, HTML_MAX_LENGTH, Model, ModelPrototype, ModelRegistry, ModelStatics, PASSWD_MAX, PASSWD_MIN, SCHEMA, SCHEMA_COUNT, STRING_MAX, TYPE_ATTR, URL_MAX_LENGTH, _ArrayPush, _Map2Obj, _ModelTypes, _Set2Array, _arrToModelList, _arrayProto, _checkIsNumber, _clone, _compileNested, _compileNestedArray, _compileNestedObject, _compileSchema, _create, _defaultDescriptor, _defineDescriptor, _defineDescriptorWrapper, _defineProperties, _defineProperty, _descriptorCompilers, _fastInstanceConvert, _has, _instanceConvert, _isPlainObject, _jsonPretty, _owns, _plainObjPrototype, _schemaDescriptor, _setPrototypeOf, _toJSONCleaner;
  /**
   * Model
   */

  // String
  STRING_MAX = 3000; // String max length
  HTML_MAX_LENGTH = 10000; // HTML max length
  PASSWD_MIN = 8; // password min length
  PASSWD_MAX = 100; // password max length
  URL_MAX_LENGTH = 3000; // URL max length
  DATA_URL_MEX_LENGTH = 30000; // Data URL max length
  
  // schema attribute descriptor count
  SCHEMA_COUNT = 5; // @see schema/schema.tempate.js for more info
  
  // hex check
  HEX_CHECK = /^[0-9a-f]$/i;
  // Email check
  EMAIL_CHECK = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  
  // symbols
  SCHEMA = Symbol('Model schema');
  DESCRIPTOR = Symbol('Descriptor');
  TYPE_ATTR = '_type'; // extra attr inside object, refers its Model
  
  // methods
  _create = Object.create;
  _setPrototypeOf = Object.setPrototypeOf;
  _defineProperties = Object.defineProperties;
  _defineProperty = Object.defineProperty;
  _has = Reflect.has;
  _owns = function(obj, property) {
    return Object.hasOwnProperty.call(obj, property);
  };
  
  // Array
  _ArrayPush = Array.prototype.push;
  
  // check
  _isPlainObject = function(obj) {
    return obj && typeof obj === 'object' && !Array.isArray(obj);
  };
  
  // clone
  _clone = function(obj) {
    return Object.assign({}, obj);
  };
  
  // json pretty
  _jsonPretty = function(obj) {
    var _prettyJSON;
    _prettyJSON = function(k, v) {
      if (typeof v === 'function') {
        v = `[FUNCTION ${v.name}]`;
      } else if (typeof v === 'symbol') {
        v = `[SYMBOL ${v}]`;
      } else if (v instanceof Error) {
        v = {
          message: v.message,
          stack: v.stack.split("\n").slice(0, 3)
        };
      }
      return v;
    };
    return JSON.stringify(obj, _prettyJSON, "\t");
  };
  _schemaDescriptor = _create(null);
  Model = _create(_schemaDescriptor);
  // basic error log
  Model.logError = console.error.bind(console);
  
  // main
  /**
   * Main model
   */
  // Model = (instance)->
  // 	# new generic instance
  // 	if `new.target`
  // 		# could not use "new" operator and arguments in the same time
  // 		throw new Error "Remove arguments or [new] operator" if arguments.length
  // 		return
  // 	# use withoud "new" operator
  // 	else unless arguments.length
  // 		instance = Object.create Model.prototype
  // 	else if arguments.length is 1 and typeof instance is 'object' and instance
  // 		Object.setPrototypeOf instance, Model.prototype
  // 	else
  // 		throw new Error "Illegal arguments"
  // 	return instance
  // prototype
  ModelPrototype = _create(null);
  // static protoperties
  ModelStatics = _create(null);
  /* Add symbols */
  _defineProperties(Model, {
    SCHEMA: {
      value: SCHEMA // link object to it's schema
    },
    TYPE_ATTR: {
      value: TYPE_ATTR
    }
  });
  _arrayProto = _create(Array.prototype, {
    push: {
      value: function() {
        var values;
        values = Array.from(arguments);
        
        // convert all types

        // for value in values

        // push
        return _ArrayPush.apply(this, values);
      }
    }
  });
  _plainObjPrototype = {};
  ModelRegistry = _create(null);
  /**
   * Get registred Model
   */
  _defineProperty(Model, 'get', {
    value: function(modelName) {
      return ModelRegistry[modelName];
    }
  });
  /**
   * Create new Model from schema
   * @param {string} options.name - Model name, case insensitive
   * @param {plain object} options.schema - Model schema
   * @optional @param {plain object} options.static - static properties
   * @optional @param {boolean} options.setters - create setters (.setAttr -> .attr) @default true
   * @optional @param {boolean} options.getters - create getters (.getAttr -> .attr) @default false
   */
  _defineProperty(Model, 'from', {
    value: function(options) {
      var errors, model, modelName, modelProto, schema;
      if (!(arguments.length === 1 && typeof options === 'object' && options)) {
        throw new Error("Illegal arguments");
      }
      if (!('name' in options)) {
        
        // check the name of the model
        throw new Error("Model name is required");
      }
      if (typeof options.name !== 'string') {
        throw new Error("Model name expected string");
      }
      modelName = options.name.toLowerCase();
      if (modelName in ModelRegistry) {
        throw new Error(`Model alreay set: ${modelName}`);
      }
      if (!(typeof options.schema === 'object' && options.schema)) {
        
        // check and compile schema
        throw new Error("Invalid options.schema");
      }
      errors = [];
      schema = _compileSchema(options.schema, errors);
      if (errors.length) {
        throw new Error(`Schema contains ${errors.length} errors.\n ${_jsonPretty(errors)}`);
      }
      
      // Create Model
      // Use Model.fromJSON or Model.fromDB to performe recusive convertion
      model = function(instance) {
        // check for "new" operator
        if (new.target) {
          if (arguments.length) {
            throw new Error("Remove arguments or [new] operator");
          }
          return;
        }
        if (!arguments.length) {
          // return new instance if no argument
          return _create(modelProto);
        }
        if (arguments.length !== 1) {
          // throws error if illegal arguments
          throw new Error("Illegal arguments");
        }
        if (!(typeof instance === 'object' && instance)) {
          throw new Error("Illegal instance");
        }
        // convert Object
        _setPrototypeOf(instance, modelProto);
        // return instance
        return instance;
      };
      // add schema
      model[SCHEMA] = schema;
      // set model name
      _defineProperties(model, {
        name: {
          value: modelName
        }
      });
      _setPrototypeOf(model, ModelStatics);
      // add static attributes
      if ('static' in options) {
        _defineProperties(model, Object.getOwnPropertyDescriptors(options.static));
      }
      // model prototype
      modelProto = model.prototype = _create(ModelPrototype);
      // add to registry
      ModelRegistry[modelName] = model;
      // return model
      return model;
    }
  });
  /**
   * Convert instance from database
   * This will not performe any validation
   * Will do any required convertion
   */
  _defineProperties(ModelStatics, {
    /**
     * Faster model convertion
     * no validation will be performed
     * Convert an instance from DB or any trusted source
     * Any illegal attribute value will just be escaped
     * @param  {[type]} instance [description]
     * @return {[type]}          [description]
     */
    fromDB: {
      value: _fastInstanceConvert
    },
    /**
     * From unstrusted source
     * will performe validations
     * @type {[type]}
     */
    fromJSON: {
      value: _instanceConvert
    }
  });
  _fastInstanceConvert = function(instance, model) {
    var attrCheck, attrConvert, attrName, attrObj, attrSchema, e, i, len, schema, seekQueu, seekQueuIndex;
    if (!(typeof instance === 'object' && instance)) {
      throw new Error("Illegal arguments");
    }
    // get model
    switch (arguments.length) {
      case 1:
        model = this;
        break;
      case 2:
        break;
      default:
        throw new Error("Illegal arguments");
    }
    // if generator is sub-Model
    if (TYPE_ATTR in instance) {
      model = ModelRegistry[instance[TYPE_ATTR]];
      if (!model) {
        throw new Error(`Unknown model: ${instance[TYPE_ATTR]}`);
      }
    }
    // Canceled test below for performance purpose
    // throw new Error "Model [#{generator}] do not extends [#{model}]" unless generator is model or generator.prototype instanceof model
    // schema
    schema = model[SCHEMA];
    // seek
    seekQueu = [instance, schema];
    seekQueuIndex = 0;
    while (seekQueuIndex < seekQueu.length) {
      // load args
      instance = seekQueu[seekQueuIndex];
      schema = seekQueu[++seekQueuIndex];
      ++seekQueuIndex;
      // convert Object
      obj[SCHEMA] = schema;
      _setPrototypeOf(obj, schema[1]);
      // go through attributes
      i = 9;
      len = schema.length;
      while (i < len) {
        // load attr info
        attrName = schema[i];
        attrCheck = schema[++i];
        attrConvert = schema[++i];
        attrSchema = schema[++i];
        ++i;
        if (!_owns(obj, attrName)) {
          // check for attribute
          continue;
        }
        attrObj = obj[attrName];
        // continue if is null or undefined
        if (attrObj === (void 0) || attrObj === null) {
          delete obj[attrName];
          continue;
        }
        try {
          // check / convert
          // convert type
          if (!attrCheck(attrObj)) {
            attrObj = obj[attrName] = attrConvert(attrObj);
          }
          // if is plain object, add to next subobject to check
          if (typeof attrObj === 'object' && attrObj) {
            seekQueu.push(attrObj, attrSchema);
          }
        } catch (error) {
          e = error;
          delete ele[attrName];
          Model.logError('DB CONV', e);
        }
      }
    }
    // return instance
    return instance;
  };
  _instanceConvert = function(instance, model) {
    var attrCheck, attrConvert, attrName, attrObj, attrSchema, e, i, len, schema, seekQueu, seekQueuIndex;
    if (!(typeof instance === 'object' && instance)) {
      throw new Error("Illegal arguments");
    }
    // get model
    switch (arguments.length) {
      case 1:
        model = this;
        break;
      case 2:
        break;
      default:
        throw new Error("Illegal arguments");
    }
    // if generator is sub-Model
    if (TYPE_ATTR in instance) {
      model = ModelRegistry[instance[TYPE_ATTR]];
      if (!model) {
        throw new Error(`Unknown model: ${instance[TYPE_ATTR]}`);
      }
    }
    // Canceled test below for performance purpose
    // throw new Error "Model [#{model}] do not extends [#{model}]" unless model is model or model.prototype instanceof model
    // schema
    schema = model[SCHEMA];
    // seek
    seekQueu = [instance, schema];
    seekQueuIndex = 0;
    while (seekQueuIndex < seekQueu.length) {
      // load args
      instance = seekQueu[seekQueuIndex];
      schema = seekQueu[++seekQueuIndex];
      ++seekQueuIndex;
      // convert Object
      obj[SCHEMA] = schema;
      _setPrototypeOf(obj, schema[1]);
      // go through attributes
      i = 9;
      len = schema.length;
      while (i < len) {
        // load attr info
        attrName = schema[i];
        attrCheck = schema[i + 1];
        attrConvert = schema[i + 2];
        attrSchema = schema[i + 3];
        i += SCHEMA_COUNT;
        if (!_owns(obj, attrName)) {
          // check for attribute
          continue;
        }
        attrObj = obj[attrName];
        // continue if is null or undefined
        if (attrObj === (void 0) || attrObj === null) {
          delete obj[attrName];
          continue;
        }
        try {
          // check / convert
          // convert type
          if (!attrCheck(attrObj)) {
            attrObj = obj[attrName] = attrConvert(attrObj);
          }
          // if is plain object, add to next subobject to check
          if (typeof attrObj === 'object' && attrObj) {
            seekQueu.push(attrObj, attrSchema);
          }
        } catch (error) {
          e = error;
          delete ele[attrName];
          Model.logError('DB CONV', e);
        }
      }
    }
    // return instance
    return instance;
  };
  
  // schema

  // includes
  /**
   * Define descriptor
   * @param {object} options.get	- descriptors using GET method
   * @param {object} options.fx	- descriptors using functions
   * @param {function} options.compile	- compilation of result
   */
  _descriptorCompilers = []; // set of descriptor compilers
  _defineDescriptor = function(options) {
    var k, ref1, ref2, v;
    // getters
    if ('get' in options) {
      ref1 = options.get;
      for (k in ref1) {
        v = ref1[k];
        _defineProperty(_schemaDescriptor, k, {
          get: _defineDescriptorWrapper(v)
        });
      }
    }
    // functions
    if ('fx' in options) {
      ref2 = options.fx;
      for (k in ref2) {
        v = ref2[k];
        _defineProperty(_schemaDescriptor, k, {
          value: _defineDescriptorWrapper(v)
        });
      }
    }
    // compile
    if ('compile' in options) {
      _descriptorCompilers.push(options.compile);
    }
  };
  _defaultDescriptor = function() {
    var desc, obj;
    // create descriptor
    desc = _create(null);
    // return schema descriptor
    obj = _create(_schemaDescriptor, {
      [DESCRIPTOR]: {
        value: desc
      }
    });
    desc._ = obj;
    return obj;
  };
  _defineDescriptorWrapper = function(fx) {
    return function() {
      var desc;
      desc = this === Model ? _defaultDescriptor() : this;
      // exec fx
      fx.apply(desc[DESCRIPTOR], arguments);
      // chain
      return desc;
    };
  };
  _toJSONCleaner = function(obj, attrToRemove) {
    var k, result, v;
    result = _create(null);
    for (k in obj) {
      v = obj[k];
      if (indexOf.call(attrToRemove, k) < 0) {
        result[k] = v;
      }
    }
    _setPrototypeOf(result, Object.getPrototypeOf(obj));
    return result;
  };
  /**
   * JSON ignore
   */
  _defineDescriptor({
    // JSON getters
    get: {
      jsonIgnore: function() {
        return this.jsonIgnore = 3; // ignore json, 3 = 11b = ignoreSerialize | ignoreParse
      },
      jsonIgnoreStringify: function() {
        return this.jsonIgnore = 1; // ignore when serializing: 1= 1b
      },
      jsonIgnoreParse: function() {
        return this.jsonIgnore = 2; // ignore when parsing: 2 = 10b
      },
      jsonEnable: function() {
        return this.jsonIgnore = 0; // include this attribute with JSON, @default
      }
    },
    // Compile Prototype and schema
    compile: function(attr, schema, proto) {
      var ignoreJSONAttr, jsonIgnore;
      jsonIgnore = this.jsonIgnore;
      // do not serialize attribute
      if (jsonIgnore & 1) {
        ignoreJSONAttr = schema[3];
        if (ignoreJSONAttr) {
          ignoreJSONAttr.push(attr);
        } else {
          ignoreJSONAttr = schema[3] = [attr];
          _defineProperties(proto, {
            toJSON: function() {
              return _toJSONCleaner(this, ignoreJSONAttr);
            }
          });
        }
      }
      // ignore when parsing
      if (jsonIgnore & 2) {
        //TODO add this to "model.fromJSON"
        (schema[4] != null ? schema[4] : schema[4] = []).push(attr);
      }
    }
  });
  /**
   * Virtual methods
   */
  _defineDescriptor({
    get: {
      virtual: function() {
        return this.virtual = true;
      },
      transient: function() {
        return this.virtual = true;
      },
      persist: function() {
        return this.virtual = false;
      }
    },
    compile: function(attr, schema, proto) {
      var virtualAttr;
      virtualAttr = schema[6];
      if (virtualAttr) {
        virtualAttr.push(attr);
      } else {
        virtualAttr = schema[6] = [attr];
      }
    }
  });
  /**
   * Set attribute as required
   */
  // implemented for each db engine
  // _defineProperties proto, toDB: -> _toJSONCleaner this, virtualAttr
  _defineDescriptor({
    get: {
      required: function() {
        return this.required = true;
      },
      optional: function() {
        return this.required = false;
      }
    },
    compile: function(attr, schema, proto) {
      var name1;
      if (this.required) {
        (schema[name1 = SCHEMA.required] != null ? schema[name1] : schema[name1] = []).push(attr);
      }
    }
  });
  /**
   * Set an object as freezed or extensible
   */
  _defineDescriptor({
    get: {
      freeze: function() {
        return this.extensible = false;
      },
      extensible: function() {
        return this.extensible = true;
      }
    }
  });
  // compile: (attr, schema, proto)->
  // 	#TODO
  // 	schema[SCHEMA.extensible] = @extensible isnt off
  // 	return
  /**
   * Default value
   * getters / setters
   * .default(8).default('static value').default(true) # default static value
   * .default(window) # static value
   * .default({}) # be careful !! some object will set for all instances
   * .default(=>{}) # create new object for each instance once.
   * .default(-> this.attr ) # generating default value from function (will be called once)
   * .default(Date.now) # generating default value from function (will be called once)
   *
   * .get(-> value)
   * .set(-> value)
   */
  _defineDescriptor({
    fx: {
      default: function(value) {
        if (arguments.length !== 1) {
          throw new Error('Illegal arguments');
        }
        // when default value is function, wrap it inside getter
        if (typeof value === 'function') {
          this.getter = function() {
            var vl;
            vl = deflt.call(this);
            _defineProperty(this, attr, {
              value: vl
            });
            return vl;
          };
        } else {
          // otherwise, it static value (be careful for objects!)
          this.default = value;
        }
      },
      getter: function(fx) {
        if (arguments.length !== 1) {
          throw new Error("Illegal arguments");
        }
        if (typeof fx !== 'function') {
          throw new Error("function expected");
        }
        if (fx.length !== 0) {
          throw new Errro("Getter expects no argument");
        }
        this.getter = fx;
      },
      setter: function(fx) {
        if (arguments.length !== 1) {
          throw new Error("Illegal arguments");
        }
        if (typeof fx !== 'function') {
          throw new Error("function expected");
        }
        if (fx.length !== 1) {
          throw new Errro("Setter expects signature: function(value){}");
        }
        this.setter = fx;
      },
      /**
       * Alias
       * @example
       * .alias('attrName')	# alias to this attribute
       * .alias(-> getter_expr)# alias to .getter(-> getter_expr)
       */
      alias: function(value) {
        if (arguments.length !== 1) {
          throw new Error("Illegal arguments");
        }
        // alias to attribute
        if (typeof value === 'string') {
          this.getter = function() {
            return this[value];
          };
        // getter
        } else if (typeof value === 'function') {
          this._.getter(value);
        }
      }
    },
    compile: function(attr, schema, proto) {
      if (typeof this.getter === 'function' || typeof this.setter === 'function') {
        _defineProperty(proto, attr, {
          get: this.getter,
          set: this.setter
        });
      } else if (_owns(this, 'default')) {
        _defineProperty(proto, attr, {
          value: this.default
        });
      }
    }
  });
  /**
   * Assertions
   * Used when validating data
   * @example
   * .assert(true)
   * .assert(true, 'Optional Error message')
   * .assert((data)-> data.isTrue())
   * .assert((data)-> throw new Error "Error message: #{data}")
   * .assert(async (data)-> asyncOp(data))
   */
  _defineDescriptor({
    fx: {
      assert: function(assertion, optionalMessage) {
        var assertObj, k, ref1, v, vl;
        // assertion object
        if (typeof assertion === 'object' && assertion) {
          if (optionalMessage) {
            throw new Error("Could not set optional message when configuring predefined assertion, use .assert(function(data){}, 'optional message') instead.");
          }
          assertObj = this.assertObj != null ? this.assertObj : this.assertObj = _create(null);
          for (k in assertion) {
            v = assertion[k];
            assertObj[k] = v;
          }
        } else {
          if ((ref1 = arguments.length) !== 1 && ref1 !== 2) {
            throw new Error("Illegal arguments");
          }
          if (optionalMessage && typeof optionalMessage !== 'string') {
            throw new Error("Optional message expected string");
          }
          // convert to function
          if (typeof assertion !== 'function') {
            vl = assertion;
            assertion = function(data) {
              return data === vl;
            };
          }
          // add to assertions
          (this.asserts != null ? this.asserts : this.asserts = []).push(assertion, optionalMessage);
        }
      },
      // wrappers
      length: function(value) {
        if (arguments.length !== 1) {
          throw new Error("Illegal arguments");
        }
        return (this.assertObj != null ? this.assertObj : this.assertObj = _create(null)).length = value;
      },
      min: function(min) {
        if (arguments.length !== 1) {
          throw new Error("Illegal arguments");
        }
        return (this.assertObj != null ? this.assertObj : this.assertObj = _create(null)).min = min;
      },
      max: function(max) {
        if (arguments.length !== 1) {
          throw new Error("Illegal arguments");
        }
        return (this.assertObj != null ? this.assertObj : this.assertObj = _create(null)).max = max;
      },
      between: function(min, max) {
        var assertObj;
        if (arguments.length !== 2) {
          throw new Error("Illegal arguments");
        }
        assertObj = this.assertObj != null ? this.assertObj : this.assertObj = _create(null);
        assertObj.min = min;
        assertObj.max = max;
      },
      match: function(regex) {
        if (arguments.length !== 1) {
          throw new Error("Illegal arguments");
        }
        (this.assertObj != null ? this.assertObj : this.assertObj = _create(null)).match = regex;
      }
    },
    compile: function(attr, schema, proto, attrPos) {
      var assertC, assertGen, asserts, k, ref1, type, typeAssertions, v;
      // add basic asserts
      if (_owns(this, 'assertObj')) {
        // get type
        type = this.type;
        if (!type) {
          throw new Error("No type specified to use predefined assertions. Use assert(function(data){}) instead");
        }
        typeAssertions = type.assertions;
        if (!typeAssertions) {
          throw new Error(`No assertions predefined for type [${type.name}]. Use assert(function(data){}) instead`);
        }
        // go through assertions
        asserts = this.asserts != null ? this.asserts : this.asserts = [];
        // generate assertion
        assertGen = function(attr, assert, value) {
          return function(data) {
            return assert(data, value);
          };
        };
        ref1 = this.assertObj;
        // iterations
        for (k in ref1) {
          v = ref1[k];
          if (!_owns(typeAssertions, k)) {
            throw new Error(`No predefined assertion [${k}] on type [${type.name}]`);
          }
          // check value
          assertC = typeAssertions[k];
          assertC.check(v);
          // add assertion
          asserts.push(assertGen(k, assertC.assert, v), null); // null represents the optional error message
        }
      }
      // add asserts
      if (_owns(this, 'asserts')) {
        schema[attrPos + 3] = this.asserts;
      }
    }
  });
  /* pipe */
  _defineDescriptor({
    fx: {
      pipe: function(fx) {
        if (arguments.length !== 1) {
          throw new Error("Illegal arguments");
        }
        if (typeof fx !== 'function') {
          throw new Error("Expected function");
        }
        (this.pipe != null ? this.pipe : this.pipe = []).push(fx);
      }
    },
    compile: function(attr, schema, proto, attrPos) {
      if (_owns(this, 'pipe')) {
        return schema[attrPos + 4] = this.pipe;
      }
    }
  });
  /**
   * toJSON / toDB
   */
  _defineDescriptor({
    fx: {
      toJSON: function(fx) {
        if (arguments.length !== 1) {
          throw new Error("Illegal arguments");
        }
        if (typeof fx !== 'function') {
          throw new Error("Expected function");
        }
        this.toJSON = fx;
      },
      toDB: function(fx) {
        if (arguments.length !== 1) {
          throw new Error("Illegal arguments");
        }
        if (typeof fx !== 'function') {
          throw new Error("Expected function");
        }
        this.toDB = fx;
      }
    },
    compile: function(attr, schema, proto, attrPos) {
      var name1, name2;
      if (this.toJSON) {
        (schema[name1 = SCHEMA.toJSON] != null ? schema[name1] : schema[name1] = []).push(attr, this.toJSON);
      }
      if (this.toDB) {
        (schema[name2 = SCHEMA.toDB] != null ? schema[name2] : schema[name2] = []).push(attr, this.toJSON);
      }
    }
  });
  /**
   * Value
   * @example
   * .value(Number) equivalent to: Number
   * .value(sub-schema) equivalent to: sub-schema
   * .value(Model.Int) equivalent to: Model.Int
   * .value(function(){}) equivalent to: function(){}
   */
  _defineDescriptor({
    fx: {
      value: function(arg) {
        var k, t, v;
        if (arguments.length !== 1) {
          throw new Error("Illegal arguments");
        }
        if (arg === Model) {
          throw new Error('Illegal use of "Model" keyword');
        }
        if (this.nestedObj || this.arrItem || this.protoMethod) {
          throw new Error("Illegal use of nested object");
        }
        // check if function
        if (typeof arg === 'function') {
          // check if registred type
          if ((t = _ModelTypes[arg.name]) && t.name === arg) {
            arg = Model[arg.name];
          // if date.now, set it as default value
          } else if (arg === Date.now) {
            arg = Model.default(arg);
          } else {
            // else add this function as prototype property
            this.protoMethod = arg;
            return;
          }
        // if it is an array of objects
        } else if (Array.isArray(arg)) {
          arg = _arrToModelList(arg);
        // nested object
        } else if (typeof arg === 'object') {
          if (!_owns(arg, DESCRIPTOR)) {
            this._.Object;
            this.nestedObj = arg;
            return;
          }
        } else {
          throw new Error("Illegal attribute descriptor");
        }
        // merge
        arg = arg[DESCRIPTOR];
        for (k in arg) {
          v = arg[k];
          this[k] = v;
        }
      },
      compile: function(attr, schema, proto, attrPos) {
        var objSchema;
        // prototype method
        if (_owns(this, 'protoMethod')) {
          _defineProperty(proto, attr, {
            value: this.protoMethod
          });
        } else if (this.nestedObj) {
          if (this.type !== _ModelTypes.Object) {
            // will be compiled, just to avoid recursivity
            throw new Error('Illegal use of nested objects');
          }
          // create object schema
          // [schemaType, proto, extensible, ignoreJSON, ignoreParse, requiredAttributes, virtualAttributes, toJSON, toDB]
          objSchema = new Array(9);
          // objSchema[0] = 1 # -1: means object not yeat compiled
          // objSchema[1] = _create _plainObjPrototype
          objSchema[2] = this.extensible || false;
          delete this.extensible;
          schema[attrPos + 5] = objSchema;
        }
      }
    }
  });
  /**
   * List
   * @example
   * .list(Number)
   * .list({sub-schema})
   * .list(Model.Int)
   * .list(Model.list(...))
   * .list(Number, {prototype methods})
   * .list Number
   * 		sort: function(cb){}
   * 		length: Model.getter(...).setter(...)
   */
  _defineDescriptor({
    fx: {
      list: function(arg, prototype) {
        var ek, ev, k, proto, ref, ref1, t, v;
        if ((ref1 = arguments.length) !== 1 && ref1 !== 2) {
          throw new Error("Illegal arguments");
        }
        if (this.nestedObj || this.arrItem) {
          throw new Error("Illegal use of list");
        }
        // set type as array
        this._.Array;
        // check prototype
        proto = _create(null);
        if (arguments.length === 2) {
          if (!_isPlainObject(prototype)) {
            throw new Error("Illegal prototype");
          }
          for (k in prototype) {
            v = prototype[k];
            // getter/setter
            if (v && typeof v === 'object') {
              if (v[DESCRIPTOR]) {
                v = v[DESCRIPTOR];
                if (!(function() {
                  var results;
                  results = [];
                  for (ek in v) {
                    ev = v[ek];
                    results.push(ek === '_' || ek === 'getter' || ek === 'setter');
                  }
                  return results;
                })()) {
                  // check for getter and setter only
                  throw new Error(`Only 'getter' and 'setter' are accepted as list prototype attribute. [${ek}] detected.`);
                }
                if (v.getter || v.setter) {
                  _defineProperty(proto, k, {
                    get: v.getter,
                    set: v.setter
                  });
                } else {
                  throw new Error("getter or setter is required");
                }
              } else {
                throw new Error(`Illegal list prototype attribute: ${k}, use Model.getter(...) instead`);
              }
            // reject types
            } else if (v === Model || (ref = _ModelTypes[v.name] && ref.name === v)) {
              throw new Error("Only methods, setters, getters are expected as list prototype property");
            } else {
              // method or static value
              _defineProperty(proto, k, {
                value: v
              });
            }
          }
        }
        _setPrototypeOf(proto, _arrayProto);
        this.arrProto = proto;
        // arg
        // predefined type
        if (typeof arg === 'function') {
          if (!((t = _ModelTypes[arg.name]) && t.name === arg)) {
            throw new Error('Illegal argument');
          }
          arg = Model[arg.name];
        // nested list
        } else if (Array.isArray(arg)) {
          arg = _arrToModelList(arg);
        } else if (!(arg && typeof arg === 'object' && _owns(arg, DESCRIPTOR))) {
          throw new Error(`Illegal argument: ${arg}`);
        }
        this.arrItem = arg;
      }
    },
    compile: function(attr, schema, proto, attrPos) {
      var arrItem, objSchema, ref1, tp;
      if (this.arrItem) {
        if (this.type !== _ModelTypes.Array) {
          throw new Error('Illegal use of nested Arrays');
        }
        
        // create object schema
        objSchema = new Array(9);
        objSchema[0] = 2; // -2: means list not yeat compiled
        objSchema[1] = this.arrProto;
        
        // items
        arrItem = this.arrItem;
        tp = objSchema[2] = arrItem.type;
        objSchema[3] = tp.check;
        objSchema[4] = tp.convert;
        // nested object or array
        if ((ref1 = arrItem.type) === _ModelTypes.Object || ref1 === _ModelTypes.Array) {
          objSchema[5] = new Array(9);
        }
        schema[attrPos + 5] = objSchema;
      }
    }
  });
  
  // convert data to Model list
  _arrToModelList = function(attrV) {
    switch (attrV.length) {
      case 1:
        return Model.list(attrV[0]);
      case 0:
        return Model.list(Model.Mixed);
      default:
        throw new Error(`One type is expected for Array, ${attrV.length} are given.`);
    }
  };
  _compileSchema = function(schema, errors) {
    var compiledSchema, path, seekQueue, seekQueueIndex;
    if (!(schema && typeof schema === 'object')) {
      // prepare schema
      throw new Error("Illegal argument");
    }
    
    // compiled schema, @see schema.template.js for more information
    compiledSchema = new Array(6);
    //  use queu instead of recursivity to prevent
    //  stack overflow and increase performance
    //  queu format: [shema, path, ...]
    seekQueue = [schema, compiledSchema, []];
    seekQueueIndex = 0;
    // seek through schema
    while (seekQueueIndex < seekQueue.length) {
      // load data from Queue
      schema = seekQueue[seekQueueIndex];
      compiledSchema = seekQueue[++seekQueueIndex];
      path = seekQueue[++seekQueueIndex];
      ++seekQueueIndex;
      // compile
      _compileNested(schema, compiledSchema, path, seekQueue, errors);
    }
    // compiled schema
    return compiledSchema;
  };
  /**
   * Compile nested object or array
   */

  _compileNested = function(nestedObj, compiledSchema, path, seekQueue, errors) {
    var nestedDescriptor;
    if (!_owns(nestedObj, DESCRIPTOR)) {
      // convert to descriptor
      nestedObj = Model.value(nestedObj);
    }
    // create compiled schema
    nestedDescriptor = nestedObj[DESCRIPTOR];
    if (nestedDescriptor.type === _ModelTypes.Object) {
      return _compileNestedObject(nestedDescriptor, compiledSchema, path, seekQueue, errors);
    } else if (nestedDescriptor.type === _ModelTypes.Array) {
      return _compileNestedArray(nestedDescriptor, compiledSchema, path, seekQueue, errors);
    } else {
      throw new Error("Schema could be Object or Array only!");
    }
  };
  _compileNestedObject = function(nestedDescriptor, compiledSchema, path, seekQueue, errors) {
    var arrSchem, attrN, attrPos, attrV, comp, err, j, len1, nxtSchema, proto, ref1, results;
    compiledSchema[0] = 1; // uncompiled object
    proto = compiledSchema[1] = _create(_plainObjPrototype);
    // go through object attributes
    attrPos = 9;
    ref1 = nestedDescriptor.nestedObj;
    results = [];
    for (attrN in ref1) {
      attrV = ref1[attrN];
      try {
        if (attrV === Model) {
          // check not Model
          throw new Error("Illegal use of Model");
        }
        if (!_owns(attrV, DESCRIPTOR)) {
          // convert to descriptor
          attrV = Model.value(attrV);
        }
        // get descriptor
        attrV = attrV[DESCRIPTOR];
        compiledSchema[attrPos] = attrN;
// compile: (attr, schema, proto, attrPos)
        for (j = 0, len1 = _descriptorCompilers.length; j < len1; j++) {
          comp = _descriptorCompilers[j];
          comp.call(attrV, attrN, compiledSchema, proto, attrPos);
        }
        if (attrV.extensible) {
          // check for illegal use of "extensible"
          throw new Error('Illegal use of "extensible" keyword');
        }
        // next schema
        nxtSchema = compiledSchema[attrPos + 5];
        if (nxtSchema) {
          // nested object
          if (nxtSchema[0] === 1) {
            if (!attrV.nestedObj) {
              throw new Error('Nested obj required');
            }
            seekQueue.push(nxtSchema, attrV.nestedObj, path.join(attrN));
          // nested array
          } else if (nxtSchema[0] === 2) {
            arrSchem = nxtSchema[5];
            if (arrSchem) {
              if (!attrV.arrItem) {
                throw new Error('Nested obj required');
              }
              seekQueue.push(arrSchem, attrV.arrItem, path.join(attrN, '*'));
            }
          } else {
            // unknown
            throw new Error(`Unknown schema type: ${nxtSchema[0]}`);
          }
        }
        // next attr position
        results.push(attrPos += 6);
      } catch (error) {
        err = error;
        results.push(errors.push({
          path: path.join(attrN),
          error: err
        }));
      }
    }
    return results;
  };
  _compileNestedArray = function(nestedDescriptor, compiledSchema, path, seekQueue, errors) {
    var arrItem, arrSchem, ref1, tp;
    if (!_owns(nestedDescriptor, 'arrItem')) {
      throw new 'Inexpected array schema';
    }
    compiledSchema[0] = 2; // uncompiled Array
    compiledSchema[1] = nestedDescriptor.arrProto;
    // item
    arrItem = this.arrItem;
    tp = compiledSchema[2] = arrItem.type;
    compiledSchema[3] = tp.check;
    compiledSchema[4] = tp.convert;
    // nested object or array
    if ((ref1 = arrItem.type) === _ModelTypes.Object || ref1 === _ModelTypes.Array) {
      arrSchem = compiledSchema[5] = new Array(9);
      seekQueue.push(arrSchem, arrItem.arrItem || arrItem.nestedObj, path.join('*'));
    }
  };
  
  // Types
  /**
  * Types
   */
  /**

   * convert Map to Object

   */
  _Map2Obj = function(data) {
    var k, v, value;
    value = _create(null);
    for (k in data) {
      v = data[k];
      if (typeof k === 'number') {
        value[k] = v;
      } else if (typeof k === 'string') {
        if (k === '__proto__') {
          throw new Error('Could not serialize property "__proto__"');
        }
        value[k] = v;
      } else {
        throw new Error('Could not serialize Map');
      }
    }
    return value;
  };
  _Set2Array = function(data) {
    return Array.from(data);
  };
  _checkIsNumber = function(value) {
    if (!(Number.isSafeInteger(value) && value >= 0)) {
      throw new Error("Expected positive integer");
    }
  };
  _ModelTypes = Object.create(null);
  /**
   * Add / override Model types
   * @param {string} options.name - name of the type
   * @param {function} options.check - check the type, returns boolean or throws exception
   * @param {function} options.convert - convert logic of the value, returns new value or throws exception (when parsing JSON or DB)
   * @optional @param {function} options.assert - assertion on the value
   * @optional @param {function} options.pipe - operation to do on the value when first add
   * @optional @param {function} options.toJSON - returns value of JSON representation
   * @optional @param {function} opitons.toDB - returns value to be stored on the database
   */
  _defineProperty(Model, 'type', {
    value: function(options) {
      var ext, j, k, len1, name, ref1, typeDef, typeKey;
      if (arguments.length !== 1 || typeof options !== 'object' || !options) {
        throw new Error('Illegal Arguments');
      }
      if (!options.name) {
        throw new Error('Type name is required');
      }
      
      // Type name
      typeKey = name = options.name;
      if (typeof name === 'function') {
        name = name.name;
      }
      if (typeof name !== 'string') {
        throw new Error(`Illegal name: ${options.name}`);
      }
      if (!/^[A-Z][a-zA-Z0-9_-]+$/.test(name)) {
        throw new Error(`Invalid type name: ${name}. must match ^[A-Z][a-zA-Z0-9_-]+$`);
      }
      
      // get name
      typeDef = _ModelTypes[name];
      if (typeDef) {
        if (typeDef.name !== typeKey) { // new type
          // throw error if two different functions with some name
          throw new Error(`Function with same name [${name}] already set. Please choose functions with different names`);
        }
      } else {
        // extends
        if ('extends' in options) {
          ext = options.extends;
          if (typeof ext === 'function') {
            ext = ext.name;
          } else if (typeof ext !== 'string') {
            throw new Error("Illegal extend");
          }
          typeDef = _ModelTypes[ext];
          if (!typeDef) {
            throw new Error(`Could not found parent type: ${ext}`);
          }
          typeDef = _clone(typeDef);
        } else {
          typeDef = _create(null);
        }
        _ModelTypes[name] = typeDef;
        if (!((typeof options.check === 'function') || ('check' in typeDef))) {
          // check
          throw new Error("Option [check] is required function");
        }
        if (name in Model) {
          throw new Error(`[${name}] is a reserved name`);
        }
        // define descriptor
        _defineDescriptor({
          get: {
            [name]: function() {
              var assertObj, k, ref1, v;
              this.type = typeDef;
              // define asserts
              if (typeDef.assert) {
                assertObj = this.assertObj != null ? this.assertObj : this.assertObj = _create(null);
                ref1 = typeDef.assert;
                for (k in ref1) {
                  v = ref1[k];
                  if (!_owns(assertObj, k)) {
                    assertObj[k] = v;
                  }
                }
              }
              if (typeof typeDef.pipe === 'function') {
                // define pipe
                (this.pipe != null ? this.pipe : this.pipe = []).push(typeDef.pipe);
              }
              if (typeof typeDef.toJSON === 'function') {
                // define toJSON
                if (this.toJSON == null) {
                  this.toJSON = typeDef.toJSON;
                }
              }
              if (typeof typeDef.toDB === 'function') {
                // define toDB
                if (this.toDB == null) {
                  this.toDB = typeDef.toDB;
                }
              }
            }
          }
        });
      }
      ref1 = ['check', 'convert', 'assert', 'assertions', 'pipe', 'toJSON', 'toDB'];
      // set check
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        k = ref1[j];
        if (options[k]) {
          typeDef[k] = options[k];
        }
      }
      return this;
    }
  });
  /**
   * define type compiler
   */
  _defineDescriptor({
    compile: function(attr, schema, proto, attrPos) {
      var type;
      type = this.type;
      if (type) {
        schema[attrPos + 1] = type.check;
        schema[attrPos + 2] = type.convert;
      }
    }
  });
  /**
   * Predefined types
   */
  /**
   * Basic
   */
  Model.type({
    name: 'Object',
    check: function(data) {
      return typeof data === 'object' && !Array.isArray(data);
    },
    convert: function() {
      throw new Error('Invalid Object');
    }
  }).type({
    name: 'Array',
    check: function(data) {
      return Array.isArray(data);
    },
    convert: function(data) {
      return [data]; // accept to have the element directly when array contains just one element
    },
    assertions: {
      min: {
        check: _checkIsNumber,
        assert: function(data, min) {
          if (data.length < min) {
            throw new Error(`Array length [${data.length}] is less then ${min}`);
          }
        }
      },
      max: {
        check: _checkIsNumber,
        assert: function(data, max) {
          if (data.length > max) {
            throw new Error(`Array length [${data.length}] is greater then ${max}`);
          }
        }
      },
      length: {
        check: _checkIsNumber,
        assert: function(data, len) {
          if (data.length !== len) {
            throw new Error(`Array length [${data.length}] expected ${len}`);
          }
        }
      }
    }
  /**
   * Boolean
   */
  }).type({
    name: Boolean,
    check: function(data) {
      return typeof data === 'boolean';
    },
    convert: function(data) {
      return !!data;
    }
  /**
   * Number
   */
  }).type({
    name: Number,
    check: function(data) {
      return typeof data === 'number';
    },
    convert: function(data) {
      var value;
      value = +data;
      if (isNaN(value)) {
        throw new Error(`Invalid number ${data}`);
      }
      return value;
    },
    // define assertion for this type
    assertions: {
      min: {
        check: _checkIsNumber,
        assert: function(data, min) {
          if (data < min) {
            throw new Error(`value less then ${min}`);
          }
        }
      },
      max: {
        check: _checkIsNumber,
        assert: function(data, max) {
          if (data > max) {
            throw new Error(`value exceeds ${max}`);
          }
        }
      }
    }
  /**
   * Integer
   */
  }).type({
    name: 'Int',
    extends: Number,
    check: function(data) {
      return Number.isSafeInteger(data);
    },
    convert: function(data) {
      var value;
      value = +data;
      if (!Number.isSafeInteger(value)) {
        throw new Error(`Invalid integer ${data}`);
      }
      return value;
    }
  /**
   * Positive integer
   */
  }).type({
    name: 'Unsigned',
    extends: Number,
    check: function(data) {
      return Number.isSafeInteger(data && data >= 0);
    },
    convert: function(data) {
      var value;
      value = +data;
      if (!Number.isSafeInteger(value && data >= 0)) {
        throw new Error(`Invalid positive integer ${data}`);
      }
      return value;
    }
  /**
   * Hexadicimal number (as string)
   * will be converted when number
   */
  }).type({
    name: 'Hex',
    check: function(data) {
      return typeof data === 'string' && HEX_CHECK.test(data);
    },
    convert: function(data) {
      if (typeof data !== 'number') {
        throw new Error(`Invalid Hex: ${data}`);
      }
      return data.toString(16);
    },
    assertions: {
      min: {
        check: _checkIsNumber,
        assert: function(data, min) {
          if (Number.parse(data, 16) < min) {
            throw new Error(`value less then ${min}`);
          }
        }
      },
      max: {
        check: _checkIsNumber,
        assert: function(data, max) {
          if (Number.parse(data, 16) > max) {
            throw new Error(`value greater then ${max}`);
          }
        }
      }
    }
  /**
   * Date
   */
  }).type({
    name: Date,
    check: function(data) {
      return data instanceof Date;
    },
    convert: function(data) {
      var v;
      v = new Date(data);
      if (v.toString() === 'Invalid Date') {
        throw new Error(`Invalid date: ${data}`);
      }
      return v;
    },
    assertions: {
      min: {
        check: function(value) {
          if (!(value instanceof Date)) {
            throw new Error('Expected valid date');
          }
        },
        assert: function(data, min) {
          if (value < min) {
            throw new Error(`Date before ${min}`);
          }
        }
      },
      max: {
        check: function(value) {
          if (!(value instanceof Date)) {
            throw new Error('Expected valid date');
          }
        },
        assert: function(data, max) {
          if (Number.parse(max, 16) > max) {
            throw new Error(`value greater then ${max}`);
          }
        }
      }
    }
  /**
   * Buffer
   */
  }).type({
    name: Buffer,
    check: function(data) {
      return data instanceof Buffer;
    },
    convert: function(data) {
      return new Buffer(data);
    }
  /**
   * Map
   */
  }).type({
    name: Map,
    check: function(data) {
      return data instanceof Map;
    },
    convert: function(data) {
      if (typeof data !== 'object') {
        throw new Error(`Invalid Map: ${data}`);
      }
      return new Map(Object.entries(data));
    },
    toJSON: _Map2Obj,
    toDB: _Map2Obj
  /**
   * Set
   */
  }).type({
    name: Set,
    check: function(data) {
      return data instanceof Set;
    },
    convert: function(data) {
      if (!Array.isArray(data)) {
        throw new Error(`Invalid Set: ${data}`);
      }
      return new Set(data);
    },
    toJSON: _Set2Array,
    toDB: _Set2Array
  /**
   * WeakMap
   */
  }).type({
    name: WeakMap,
    check: function(data) {
      return data instanceof WeakMap;
    },
    convert: function(data) {
      if (typeof data !== 'object') {
        throw new Error(`Invalid WeakMap: ${data}`);
      }
      return new WeakMap(Object.entries(data));
    },
    toJSON: _Map2Obj,
    toDB: _Map2Obj
  /**
   * WeakSet
   */
  }).type({
    name: WeakSet,
    check: function(data) {
      return data instanceof WeakSet;
    },
    convert: function(data) {
      if (!Array.isArray(data)) {
        throw new Error(`Invalid WeakSet: ${data}`);
      }
      return new WeakSet(data);
    },
    toJSON: _Set2Array,
    toDB: _Set2Array
  /**
   * Text
   * String as it is
   * max length is STRING_MAX
   */
  }).type({
    name: 'Text',
    check: function(data) {
      return typeof data === 'string';
    },
    convert: function(data) {
      return data.toString();
    },
    assertions: {
      min: {
        check: _checkIsNumber,
        assert: function(data, min) {
          if (data.length < min) {
            throw new Error(`String length less then ${min}`);
          }
        }
      },
      max: {
        check: _checkIsNumber,
        assert: function(data, max) {
          if (data.length > max) {
            throw new Error(`String exceeds ${max}`);
          }
        }
      },
      length: {
        check: _checkIsNumber,
        assert: function(data, len) {
          if (data.length !== len) {
            throw new Error(`String length [${data.length}] expected ${len}`);
          }
        }
      },
      // match regex
      match: {
        check: function(value) {
          if (!(value instanceof RegExp)) {
            throw new Error('Expected RegExp');
          }
        },
        assert: function(data, regex) {
          if (!regex.test(data.href)) {
            throw new Error(`Expected to match: ${regex}`);
          }
        }
      }
    },
    assert: {
      max: STRING_MAX
    }
  /**
   * String
   * HTML will be escaped
   */
  }).type({
    name: String,
    extends: 'Text',
    pipe: function(data) {
      return xss.escape(data);
    }
  /**
   * URL
   */
  }).type({
    name: URL,
    check: function(data) {
      return data instanceof URL;
    },
    convert: function(data) {
      return new URL(datadata.href || data);
    },
    assertions: {
      min: {
        check: _checkIsNumber,
        assert: function(data, min) {
          var urlLen;
          urlLen = data.href.length;
          if (urlLen < min) {
            throw new Error(`URL length [${urlLen}] is less then ${min}`);
          }
        }
      },
      max: {
        check: _checkIsNumber,
        assert: function(data, max) {
          var urlLen;
          urlLen = data.href.length;
          if (urlLen > max) {
            throw new Error(`URL length [${urlLen}] is greater then ${max}`);
          }
        }
      },
      length: {
        check: _checkIsNumber,
        assert: function(data, len) {
          var urlLen;
          urlLen = data.href.length;
          if (urlLen !== len) {
            throw new Error(`URL length [${urlLen}] expected ${len}`);
          }
        }
      },
      match: {
        check: function(value) {
          if (!(value instanceof RegExp)) {
            throw new Error('Expected RegExp');
          }
        },
        assert: function(data, regex) {
          if (!regex.test(data.href)) {
            throw new Error(`Expected to match: ${regex}`);
          }
        }
      }
    },
    assert: {
      max: URL_MAX_LENGTH
    },
    toJSON: function(data) {
      return data.href;
    },
    toDB: function(data) {
      return data.href; // save to database
    }
  /**
   * Image URL
   */
  }).type({
    name: 'Image',
    extends: URL,
    assert: {
      max: DATA_URL_MEX_LENGTH
    }
  /**
   * HTML
   * String, remove images, remove dangerous code
   */
  }).type({
    name: 'HTML',
    extends: 'Text',
    assert: {
      max: HTML_MAX_LENGTH
    },
    pipe: function(data) {
      return xss.clean(data, {
        imgs: false
      });
    }
  /**
   * HTML with images
   * remove dangerouse code
   */
  }).type({
    name: 'HTMLImgs',
    extends: 'Text',
    assert: {
      max: HTML_MAX_LENGTH
    },
    pipe: function(data) {
      return xss.clean(data, {
        imgs: true
      });
    }
  /**
   * Email
   */
  }).type({
    name: 'Email',
    extends: 'Text',
    check: function(data) {
      return typeof data === 'string' && EMAIL_CHECK.test(data);
    },
    convert: function(data) {
      throw new Error(`Invalid Email: ${data}`);
    },
    assert: {
      max: STRING_MAX
    }
  /**
   * Password
   */
  }).type({
    name: 'Password',
    extends: 'Text',
    convert: function(data) {
      throw new Error(`Invalid Password: ${data}`);
    },
    assert: {
      min: PASSWD_MIN,
      max: PASSWD_MAX
    }
  /**
   * Mongo ObjectId
   */
  }).type({
    name: 'ObjectId',
    check: function(data) {
      return typeof data === 'object' && data._bsontype === 'ObjectID';
    },
    convert: function(data) {
      return ObjectId.createFromHexString(data); //TODO make this logic
    }
  /**
   * UUID
   */
  }).type({
    name: 'UUID',
    check: function(data) {},
    convert: function(data) {}
  /**
   * Mixed
   */
  }).type({
    name: 'Mixed',
    check: function() {
      return true;
    }
  });
  
  // interface
  return module.exports = Model;
})();
