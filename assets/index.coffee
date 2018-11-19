###*
 * Model
###
Model = Object.create _schemaDescriptor


#=include consts.coffee

###*
 * Define Model properties
###
_define = (name, value)-> Object.defineProperty Model, name, value: value
_defineGetter = (name, value)-> Object.defineProperty Model, name, get: value

# schema
#=include schema/index.coffee

# Types
#=include types/index.coffee