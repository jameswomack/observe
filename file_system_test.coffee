FileSystem = require './file_system'

fileSystem = new FileSystem

fileSystem.act fileSystem, 'first.fileBufferLength', 'first.fileHidden', ->
  console.log(@get('first.fileHidden'), @get('first.fileBufferLength'))

setTimeout (=>
  fileWatcher = fileSystem.fileWatchers[Object.keys(fileSystem.fileWatchers)[0]]
  fileSystem.unwatch(fileWatcher)
), 2000

setTimeout (=>
  fileWatcher = fileSystem.fileWatchers[Object.keys(fileSystem.fileWatchers)[1]]
  fileSystem.unwatch(fileWatcher)
), 4000