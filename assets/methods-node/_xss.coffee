###*
 * Xss Module
###
@cleanHTML: (html)-> xssClean.clean html, imgs: on
@xssNoImages: (html)-> xssClean.clean html, imgs: off
@escape: (html)-> xssClean.escape html

