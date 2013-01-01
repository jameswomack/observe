Observable = require './observable'

class User extends Observable
  @accessor 'dude.username',
    get: (key) ->
      @getViaKeyPath key
    set: (key, value) ->
      @assignViaKeyPath key, "#{value.split('_')[0]} the great"

module.exports = User

