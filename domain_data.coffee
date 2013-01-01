Observable = require './observable'

class DomainData extends Observable
  dns = require 'dns'
  
  constructor: (@domainName) ->
    dns.resolve @domainName, (err, addresses) =>
      throw err if err?
      @set 'ipAddresses', addresses
    dns.resolveMx @domainName, (err, addresses) =>
      throw err if err?
      @set 'mxRecords', addresses
    dns.resolveNs @domainName, (err, addresses) =>
      throw err if err?
      @set 'nsRecords', addresses 

module.exports = DomainData