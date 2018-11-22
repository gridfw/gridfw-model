###*
 * Model
###
#=include consts.coffee

_schemaDescriptor = _create null
Model = _create _schemaDescriptor


<%
#=include template-defines.js
%>

###*
 * Define Model properties
###
_define = (name, value)-> Object.defineProperty Model, name, value: value
_defineGetter = (name, value)-> Object.defineProperty Model, name, get: value

# main
#=include main/index.coffee

# schema
#=include schema/index.coffee

# Types
#=include types/index.coffee