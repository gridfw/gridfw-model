try
	# ...
	console.log 'Begin tests'

	# console.log '-----', Object.getOwnPropertyDescriptors Model.__proto__

	User = Model.from
		name: 'user'
		# schema: Model.extensible.value
		schema: Model.value
			firstName: Model.required.jsonIgnoreStringify.String
			lastName: Model.virtual.required.jsonIgnoreStringify.String.toJSON(->'test')
			company: String
			# age: Model.Number.default(5)
			# phones: [
			# 	test:String
			# 	list: [Number]
			# ]
			# emails: Model.list String, cc:->
			
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

	Model.override
		name: 'user'
		schema:
			jobs: Model.required.list
				job1: String
			work:
				work1: Number

	Model.override
		name: 'user'
		schema:
			jobs: [
				job2: String
			]
			phone: [Number]
			work:
				work2: Number

	# console.log "User schema>>", User[Model.SCHEMA]
	# console.log "User1>>", user1.__proto__

	# create user instance
	# Model

	user1= 
		name: 'khalid'
		firstName: 'khalid'
		lastName: 'rafik'
		company: 'coredigix'
		jobs:[
			{
				job1: 'test1'
				job2: 'test2'
				job3: 'test3'
			},
			{
				job1: 'Stest1'
				job2: 'Stest2'
				job3: 'Stest3'
			}
		]
		phone: ['10215', '0231525', '524625125', '421541252', '41524251']
		emails:[{
			type:'office'
			value: 'khalid@coredigix.com'
			}]
	result = User.fromJSON user1

	console.log '--user: ', user1
	console.log '--result: ', result


	console.log '---- end test'
catch err
	console.error "uncaught error:", err
