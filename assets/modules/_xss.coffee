###*
 * XSS Filters
###
_xss= (data, options) ->
	return
_defineProperties Model,
	xss: value: _xss
	xssEscape: value: ->
	xssNoImages: value: -> (data)-> _xss data, img: no