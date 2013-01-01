fs = require 'fs'

warn = require('./logging').warn

fshoot = (name, arg, callback) ->
  fs[name] arg, (e, result) ->
    die e.stack or e  if e
    callback result


module.exports.watch = (source, action) ->
  (repeat = (ptime) =>
    return if @shouldEndWatch
    fshoot "stat", source, (arg$) ->
      mtime = undefined
      mtime = arg$.mtime
      action(arg$)  if ptime ^ mtime
      setTimeout repeat, 500, mtime

  ).call this, 0
