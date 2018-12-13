
console.log 'Begin tests'

# console.log '-----', Object.getOwnPropertyDescriptors Model.__proto__

User = Model.from
	name: 'user'
	schema: Model.extensible.value
		firstName: Model.required.jsonIgnore.String
		lastName: Model.virtual.required.jsonIgnoreStringify.String.toJSON(->'test')
		age: Model.Number.default(5)
		phones: [String]
		emails: Model.list String
		# test: Model.freeze.value
		# 	kk:
		# 		cc: Date
		# lastName: Model.String
		# email: Model.Email
		# fullName: Model.getter -> "#{@firstName} #{@lastName}"
		# class: Model.Int.required.jsonIgnore
		# website: Model.String.required
		# toString: -> "User [@fullName]"
		# hobies:[
		# 	title: String
		# 	score:
		# 		max: Number
		# 		avg: Model.Unsigned.required
		# 		doBa: ->
		# 			console.log 'baba'
		# 		def: Model.Hex.default -> 'a45f'
		# 	validated: Boolean
		# ]


# user1 = User.fromJSON {}

console.log "User schema>>", User[Model.SCHEMA]
# console.log "User1>>", user1.__proto__

console.log '---- end test'