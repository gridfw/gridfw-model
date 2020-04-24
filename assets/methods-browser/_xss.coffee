###*
 * Xss Module
###
@cleanHTML: (html)->
	throw new Error 'XSS not yet implemented for browsers.'

@escape: do ->
	txtNode= document.createTextNode('')
	txtParent= document.createElement('div')
	txtParent.appendChild txtNode
	(str)->
		txtNode.nodeValue= str
		return txtParent.innerHTML

@xssNoImages: (html)->
	throw new Error 'XSS not yet implemented for browsers.'