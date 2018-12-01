var Model, User;

Model = require('..');

console.log('Begin tests');

// console.log '-----', Object.getOwnPropertyDescriptors Model.__proto__
User = Model.from({
  name: 'user',
  schema: {
    firstName: String,
    lastName: String,
    email: Model.Email,
    fullName: Model.getter(function() {
      return `${this.firstName} ${this.lastName}`;
    }),
    class: Model.Int.required.jsonIgnore,
    website: Model.String.required,
    toString: function() {
      return "User [@fullName]";
    },
    hobies: [
      {
        title: String,
        score: {
          max: Number,
          avg: Model.Unsigned.required,
          doBa: function() {
            return console.log('baba');
          },
          def: Model.Hex.default(function() {
            return 'a45f';
          })
        },
        validated: Boolean
      }
    ]
  }
});

// user1 = User.fromJSON {}
console.log("User schema>>", User[Model.SCHEMA]);

// console.log "User1>>", user1.__proto__
console.log('---- end test');
