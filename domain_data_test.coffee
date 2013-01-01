DomainData = require './domain_data'

domainData = new DomainData 'amco.me'

domainData.defaultObserver (key, value) ->
  console.info 'D.O.', key, value
  
domainData.on 'ipAddressesSet', (key, value, keySetListenersLength) ->
  console.log(key, "keySetListenersLength: #{keySetListenersLength}")

domainData.onOnly 'ipAddressesSet', (key, value, keySetListenersLength) ->
  console.log(key, "keySetListenersLength: #{keySetListenersLength}") #demonstrates this replaces previous listener

domainData.on 'ipAddressesGet', (key, value, keyGetListenersLength) ->
  console.log(key, "keyGetListenersLength: #{keyGetListenersLength}") 

