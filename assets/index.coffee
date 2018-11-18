###*
 * Model
###
Model = Object.create null


#=include consts.coffee

###*
 * Define Model properties
###
_define = (name, value)-> Object.defineProperty Model, name, value: value
_defineGetter = (name, value)-> Object.defineProperty Model, name, get: value

# Types
#=include types/index.coffee