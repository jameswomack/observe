Observable = require './observable'
File = require './file'


class FileSystem extends Observable


  fs = require 'fs'

  
  MATCH_HIDDEN_FILE = /^\./


  constructor: ->
    super arguments...
    fs.readdir './', (err, ls) =>
      @set 'files', ls
      @watch ls[0]
      @watch ls[1]

  @::fileWatchers = {}
  
  watch: (filename) ->
    file = @fileWatchers["#{__dirname}/#{filename}"]?.file
    file ?= new File(filepath: "#{__dirname}/#{filename}")
    changedListener = ->
      console.log(arguments)
    @fileWatchers["#{__dirname}/#{filename}"] = {file: file, changedListener: changedListener}
    file.on 'changed', changedListener
    file
  
  unwatch: (fileWatcher) ->
    fileWatcher.file.removeListener 'changed', fileWatcher.changedListener 
    @fileWatchers[fileWatcher.file.get('filepath')] = undefined
    fileWatcher.file.shouldEndWatch = true
  
  @::on 'filesSet', (key, value) ->
    filename = @get('files')[0]
    filepath = "#{__dirname}/#{filename}"
    @set 'first.fileHidden', MATCH_HIDDEN_FILE.test(filename)
    
    fs.readFile filepath, (err, contentsBuffer) =>
      @set 'first.fileBufferLength', contentsBuffer.toString().length


module.exports = FileSystem