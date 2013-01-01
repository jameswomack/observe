util = require 'util'

module.exports.warn = ->
  if process.env["NODE_ENV"] == 'production'
    util.warn arguments...
  else
    console.warn arguments...