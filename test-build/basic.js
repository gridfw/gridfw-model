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
    toString: function() {
      return "User [@fullName]";
    }
  }
});

// user1 = User.fromJSON {}
console.log("typeof User>>", typeof User);

console.log("typeof User>>", User[Model.SCHEMA]);

// console.log "User1>>", user1.__proto__
console.log('---- end test');
