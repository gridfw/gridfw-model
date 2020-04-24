try
	Model= new ModelClass()
	# ...
	console.log 'Test schema ========================>'
	userSchema= Model.freeze.value
		_id:	Model.Hex.default('445a54c566b4e')
		id:		Model.alias '_id'
		firstName: Model.String.required
		lastName: Model.String
		status: Model.virtual.extensible.value
			st1: Model.default(5)
			st2: Model.value
				st21: Boolean
				st22: Model.list {
					cc:
						c2:String
				}
			bshi: -> 'yasit blu ghrfis'

		age: Model.virtual.Int.default(18).gte(18).lt(99)
		jobs: [
			title: String
			subTitle: String
			period:
				from: Date
				to: Date
		]
		jaja: Model.list(String).proto({
			cc: -> 'hello'
			khalid: -> 'khalid'
			})
		map: Model.proto({cc:15}).map String,
			a: String
			b: Model.Int
		modelSignature: -> 'hello user'

	# userSchema= Model.value
	# 	_id: Model.ObjectId
	# 	id: Model.alias '_id'
	# 	firstName: Model.required.jsonIgnoreStringify.String
	# 	lastName: Model.virtual.required.jsonIgnoreStringify.String

	# 	age: Model.Number.default(15)

	# 	jobs:[
	# 		title: String
	# 		subTitle: String
	# 		period:
	# 			from: Model.Date.required
	# 			to: Date
	# 	]

	# 	skills: [String]

	# 	networking:
	# 		Model.required
	# 		.list [Number]
	# 		.proto
	# 			test1: ->
	# 			test2: (a,b,c)->

	# 	method1: ->
	# console.log '>> user schema descriptor: ', userSchema
	
	# compile schema
	User = Model.define 'User', userSchema

	console.log '---- USER: ', User[Model.SCHEMA]
	console.log User.toString() # Print User format to console

	# console.log '>> user signature:\n', User.modelSignature()

	# # override schema
	# Model.override 'User',
	# 	id2: String
	# 	cc:
	# 		kk: Number
	# 		bb: Boolean
	# 	_id:
	# 		timestamp: Model.Unsigned
	# 		rand:	Math.random
	# 		date:	Date.now
	# 	jobs:[
	# 		title: Number
	# 		period:
	# 			to: Model.required
	# 			title: Model.String.max(500).min(0)
	# 			yoga: Model.of('Yoga').freeze.value
	# 				jj: Number
	# 				nk: Date.now
	# 	]
	# 	# addedAttr: Model.String.required
	# 	# firstName: Model.optional
	# 	# skills: [
	# 	# 	skillTitle: String
	# 	# 	skillLevel: Number
	# 	# 	]
	# 	networking:[[String]]
	# 	net: [[[[cc:Number, f:String]]]]
	# console.log '---- USER overrided: '
	# console.log User.toString() # Print User format to console
	# console.log Model.all.Yoga.toString() # Print User format to console
	# # override 2
	# Model.override
	# 	name: 'user'
	# 	schema:
	# 		skills: Model.clear.value
	# 			skillCC: String
	# 			skill2: Boolean
	# console.log '>> Overrided user signature:\n', User.modelSignature()
	# console.log '>> user schema: ', User[Model.SCHEMA]

	# console.log '-----', Object.getOwnPropertyDescriptors Model.__proto__

	Skills = Model.define 'Skills', [String]
	console.log '------ Skills'
	console.log Skills.toString()

	# # Extends
	# Member= Model.extends 'Member', 'User',
	# 	since: Date
	# 	godfather: Model.of('User')
	# 	_id:
	# 		herro: String

	# console.log Member.toString()
	# console.log User.toString()



	# # print user
	# console.log "------- user signature: \n", User.modelSignature()
			
	# 		# test: Model.freeze.value
	# 		# 	kk:
	# 		# 		cc: Date
	# 		# lastName: Model.String
	# 		# email: Model.Email
	# 		# fullName: Model.getter -> "#{@firstName} #{@lastName}"
	# 		# class: Model.Int.required.jsonIgnore
	# 		# website: Model.String.required
	# 		# toString: -> "User [@fullName]"
	# 		# hobies:[
	# 		# 	title: String
	# 		# 	score:
	# 		# 		max: Number
	# 		# 		avg: Model.Unsigned.required
	# 		# 		doBa: ->
	# 		# 			console.log 'baba'
	# 		# 		def: Model.Hex.default -> 'a45f'
	# 		# 	validated: Boolean
	# 		# ]

	# Model.override
	# 	name: 'user'
	# 	schema:
	# 		jobs: Model.required.list
	# 			job1: Model.String.required
	# 		work:
	# 			work1: Number

	# Model.override
	# 	name: 'user'
	# 	schema:
	# 		jobs: [
	# 			job2: Model.String
	# 		]
	# 		phone: [Number]
	# 		work:
	# 			work2: Number
	# 		call: (name)-> console.log '---- hello: ', name

	# # # console.log "User schema>>", User[Model.SCHEMA]
	# # # console.log "User1>>", user1.__proto__

	# # # create user instance
	# # # Model
	# console.log '-------------- user 1'
	# user1= 
	# 	name: 'khalid'
	# 	firstName: 'khalid'
	# 	lastName: 'rafik'
	# 	age: 854
	# 	company: 'coredigix'
	# 	jobs:[
	# 		{
	# 			job1: true
	# 			job2: 'test2'
	# 			job3: 'test3'
	# 		},
	# 		{
	# 			job1: 'Stest1'
	# 			job2: 'Stest2'
	# 			job3: 'Stest3'
	# 		}
	# 	]
	# 	phone: ['10215', '0231525', '421541252', '41524251']
	# 	emails:[{
	# 		type:'office'
	# 		value: 'khalid@coredigix.com'
	# 		}]
	# result = User.fromJSON user1

	# console.log '--user: ', user1
	# console.log '--result: ', result

	# console.log '---------- test 2 =====================================================>'
	# test2 = Model.from
	# 	name: 'test2'
	# 	schema: [
	# 		yy: String
	# 		name: String
	# 	]

	# console.log '---- test2: ', test2
	# obj = [{name: 'abc'}, {name: 'def'}]
	# test2.fromJSON obj

	# console.log '----obj: ', obj
	# console.log '---- end test'

	# console.log 'check "toJSON" =====================================================>'
	# UserModel2= Model.from
	# 	name: 'user2'
	# 	schema:
	# 		name: String
	# 		id: Model.ObjectId.toJSON (data)->
	# 			console.log '--- call toJSON of id'
	# 			data
	# 		list: [
	# 			attr: Model.String.toJSON (data)->
	# 				console.log '------ call  nested toJSON'
	# 				'****'
	# 		]
	# 		list2: Model
	# 			.toJSON (data)->
	# 				console.log '--* call listed toJSON'
	# 				data.map (l)-> l.id
	# 			.list
	# 				id: Number
	# 				name: String
	# 		info: Model
	# 			.toJSON (data)->
	# 				console.log '--[ call info toJSON'
	# 				{'obj': 'pppp'}
	# 			.value
	# 				name: String
	# 				age: Number

	# console.log '---- model UserModel2 created'
	# userA=
	# 	name: 'khalid'
	# 	id: '555555555'
	# 	list:[
	# 		{id: 'mmmm'}
	# 	]
	# 	list2:[
	# 		{id:1, name:'wij'}, {id:2, name: 'hak'}, {id:3, name: 'raf'}
	# 	]
	# 	info:
	# 		name: 'medo'
	# 		age: 36

	# err= UserModel2.fromJSON userA
	# console.log '----err: ', err
	# # console.log '----user JSON: ', 
	# console.log 'DB Test ========================>'
	# UserModel3= Model.from
	# 	name: 'user3'
	# 	schema:
	# 		name: Model.String.fromJSON (data)-> 'received: '+ data
	# 		lastName: Model.String
	# 		docs: Model.list Model.String.fromJSON (data)-> 'lst>> '+ data #.toJSON -> 'cccc'.jsonIgnore


	# user3= {name: 'khalid', lastName: 'rafik', age: 15, docs: ['u', 'k', 'iii']}
	# UserModel3.fromJSON user3
	# console.log 'user3: ', JSON.stringify user3

	console.log 'DATA TEST: ══════════════════════════════════════════════════════════════════'
	user=
		name: 'Khalid'
		firstName: 'khalid'
		fullName: 'RAFIK khalid'
		# age: 31
		hobbies: ['sleep', 'sellp2']
		status:
			st1:'st shit'
			cc:'ops'
			# hello: -> '7mar'
		skills: [{
			name: 'skill1'
		},{
			name: 'skill2'
		}]
		jobs: title: 'hello'
	user2= User.fromJSON user
	console.log '------- User2: ', JSON.stringify(user2, null, "\t")
	console.log '------- DB: ', user2.exportDB()
	console.log '>>>>>', User.fromJsonToDb user

catch err
	console.error "uncaught error:", err
