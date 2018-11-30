Model = require '..'

console.log 'Begin tests'

# console.log '-----', Object.getOwnPropertyDescriptors Model.__proto__

User = Model.from
	name: 'user'
	schema:
		firstName: String
		lastName: String
		email: Model.Email
		fullName: Model.getter -> "#{@firstName} #{@lastName}"
		class: Model.Int.required.jsonIgnore
		website: Model.String.required
		toString: -> "User [@fullName]"


# user1 = User.fromJSON {}

console.log "User schema>>", User[Model.SCHEMA]
# console.log "User1>>", user1.__proto__

console.log '---- end test'