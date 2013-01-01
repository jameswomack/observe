assert = require 'assert'

User = require './user'

user = new User

user.observe 'dude.username', ->
  console.log(arguments)
  
user.on 'dude.usernameSet', ->
  console.log(arguments)

user.act user, 'dude.username', 'hairColour', ->
  console.log(arguments)

user['dude.username'] = 'james_womack'

(=>
  user['hairColour'] = 'james_womack'
).delay 3000

assert.deepEqual(user.dude, user.__data.dude, "dudes not equal")
