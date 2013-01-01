EventEmitter = require('events').EventEmitter

class Observable extends EventEmitter


  sugar = require 'sugar'
    
  warn = require('./logging').warn
  
  
  @accessor = (key, options) ->
    getter = options?.get
    setter = options?.set

    Object.defineProperty(@::, key, {
      get: ->
        return if key == 'defaultObserver'
        if getter? && typeof getter == 'function'
          value = getter.call(@, key)
        else
          value = @getViaKeyPath(key)
        @emit (keyGet = "#{key}Get"), key, value, @listeners(keyGet).length
        value
      set: (value) ->
        return if key == 'defaultObserver'
        if setter? && typeof setter == 'function'
          value = setter.call(@, key, value)
        if @__data[key] != value
          @assignViaKeyPath key, value
          if @observers[key]?
            callback.call(@, key, value) for callback in @observers[key]
          else if @observers['defaultObserver']?
            callback.call(@, key, value) for callback in @observers['defaultObserver']
          @emit (keySet = "#{key}Set"), key, value, @listeners(keySet).length
          @getViaKeyPath key, @
      enumerable:true, 
      configurable:false
    })

  
  
  constructor: ->
    @setImpotently arguments...

  
  
  @::setMaxListeners 4 # Catch leaks early on
  
  @::__data = {}  
  
  @::observers = {}
  
  
  
  @::on 'newListener', (event, listener) ->
    findAll = @listeners(event).findAll (localListener) ->
      localListener.toString() == listener.toString()
    if findAllLength = findAll.length
      console.info "That listener has already been added. Count: #{findAllLength+1}"
    @
  
  
  @::on 'newObserver', (key, observer) ->
    @observers[key] ?= []
    findAll = @observers[key].findAll (localObserver) ->
      localObserver.toString() == observer.toString()
    if findAllLength = findAll.length
      console.info "The observer #{key} has already been added. Count: #{findAllLength+1}"
    @observers[key].push observer
    @
    
  
  
  applyOptionsArray: (args) ->
    args.forEach (options) =>
      @options ?= {}
      merge @options, options
      iterate options, (key) =>
        @[key] = @options[key]
    @options
  
  
  setImpotently: ->
    return if !arguments.length
    if isString(key = arguments[0]) && arguments.length == 2
      @__data[key] = arguments[1]
    else if isObjectPrimitive(options = arguments[0]) && arguments.length == 1
      iterate options, (key) =>
        @__data[key] = options[key]
    else if isArray(arguments[0]) && arguments.length == 1
      @applyOptionsArray(arguments[0])
    else if isObjectPrimitive(arguments[0]) && arguments.length > 1 && isObjectPrimitive(arguments[1])
      args = Array::slice.call arguments
      @applyOptionsArray(args)
    else if isString(arguments[0]) && arguments.length > 2 && isEven(length = arguments.length)
      args = Array::slice.call arguments
      while length
        value = args[length--]
        key   = args[length--]
        @set key, value
    else if isString(json = arguments[0]) && arguments.length == 1
      deserialized = JSON.parse(json)
      @setImpotently.call @, deserialized
    else
      warn arguments...
      throw TypeError "Invalid object sent to setImpotently"
  
  
  unset: (key) ->
    @[key] = undefined
  
  
  observe: (key, callback) ->
    accessorize @, key
    @emit 'newObserver', key, callback
  
  
  observeAndFire: (key, callback) ->
    @observe arguments...
    callback.call @, key, @[key]
  
  
  defaultObserver: (callback) ->
    @observe 'defaultObserver', callback
  
  
  forget: (key, callback) ->
    useStrict = false
    if typeof callback != 'function'
      useStrict = true
      callback = arguments[2]
    if callback?
      @observers[key] ?= []
      @observers[key].remove (localCallback) ->
        if useStrict
          localCallback == callback
        else
          localCallback.toString() == callback.toString()
    else
      @observers[key] = []
  
  
  onOnly: (key, callback) ->
    @removeAllListeners key
    @on arguments...
  
  
  doWhen: (key, method, cb, timeout=1000) ->
    if @get(key)
      method.apply(@)
    else
      @observe key, (value) =>
        return unless value?
        method.apply(@)
        @forget key
      (=> cb() unless @get key ).delay(timeout) if typeof cb is 'function'


  act: (context, keyPaths..., method) ->
    ok = true
    for k in keyPaths
      accessorize context, k
      context.observe k, (newValue, oldValue, keyPath) =>
        return unless newValue?
        ok = true
        for k in keyPaths
          ok = context[k]?
          return unless ok
        if ok
          context.forget k
          method.apply(context)
      ok = false if !context[k]?
    if ok
      context.forget k for k in keyPaths
      method.apply(context)


  toggle: (key) ->
    @set key, !@get(key)


  actOn: (context, condition, observable, key, method) ->
    if !condition
      observable.on key, (=> method.apply(context))
    else
      method.apply(context)


  unsets: (keys...) ->
    @unset k for k in keys
  
  
  assignViaKeyPath: (k, v, o) ->
    root = !o?
    o ?= @__data
    indexPath = k.split(/\./)
    if indexPath.length < 2
      o[indexPath[0]] = v
    else
      o[indexPath[0]] = {}  unless o[indexPath[0]]
      if root && !Object.getOwnPropertyNames(@).find(indexPath[0])?
        accessorize @, indexPath[0]
      o = o[indexPath.shift()]
      @assignViaKeyPath indexPath.join("."), v, o


  getViaKeyPath: (k) ->
    object = @__data
    o = {}
    copy = Object.clone(object,true)
    k.split(/\./).forEach (s) ->
      o ?= {}
      o[s] = copy?[s]
      copy = copy?[s]
      o    = o?[s]
    o
  


  accessorize = (context, k) ->
    context.constructor.accessor k if !context.__lookupGetter__(k)

  isEven = (value) ->
    value%2 == 0
  
  isString = (o) ->
    !!(typeof o == 'string' )
  
  toStringTypeCheck = (o, typeString) ->
    !!(o? && Object::toString.call(o) == "[object #{typeString}]")
  
  isObjectPrimitive = (o) ->
    toStringTypeCheck o, 'Object'
  
  isArray = (o) ->
    toStringTypeCheck o, 'Array'
  
  iterate = (options, each) ->
    keys = objectKeys(options)
    return if !keys.length
    keys.forEach each

  objectKeys = (o) ->
    if isObjectPrimitive(o) then Object.keys(o) else console.error("#{o} is not an object")
      
  toJSON = (o) ->
    JSON.stringify(o, undefined, 2)
  
  mergeDeep = (mergeInto, mergeFrom, depth) ->
    forever = !depth?
    for p of mergeFrom
      if mergeFrom[p]? && mergeFrom[p].constructor == Object && (forever or depth > 0)
        mergeInto[p] = mergeDeep((if mergeInto.hasOwnProperty(p) then mergeInto[p] else {}), mergeFrom[p], (if forever then null else depth - 1))
      else
        mergeInto[p] = mergeFrom[p]
    mergeInto

  merge = (mergeInto, mergeFrom) ->
    mergeDeep mergeInto, mergeFrom, 0

  mergeCopy = (mergeInto, mergeFrom, depth) ->
    mergeIntoCopy = mergeDeep({}, mergeInto)
    mergeDeep mergeIntoCopy, mergeFrom, depth

module.exports = Observable