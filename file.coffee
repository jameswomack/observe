Observable = require './observable'

class File extends Observable
 

  fs = require 'fs'
  WatchUtils = require './watch'
  warn = require('./logging').warn
  
      
  constructor: (options) ->
    super arguments...
    
    fs.exists options.filepath, (exists) =>
      @set 'preexistant', exists
      if @get('preexistant')
        @emit('ready')
      else
        fs.writeFile options.filepath, options.content || "\n", (e) ->
          return warn(e) if e  
          @emit('ready')


  @::shouldEndWatch = false
    
  @::on 'ready', ->
    WatchUtils.watch.call @, @get('filepath'), =>
      @emit 'changed', arguments[0]

                
module.exports = File