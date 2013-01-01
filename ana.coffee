Array::before = (o) ->
  if ((i = @indexOf(o)) != -1) and (0 < i)
    return @[i-1]
  null
  
console.log(a.before(n)) for n in (a = [0..2])


Array::after = (o) ->
  if ((i = @indexOf(o)) != -1) and (@length-1 > i)
    return @[i+1]
  null

console.log(a.after(n)) for n in (a = [0..2])


Array::between = (o1,o2) ->
  if ((i1 = @indexOf(o1)) is -1) or ((i2 = @indexOf(o2)) is -1) or (i1 >= i2)
    null
  b = []
  s = i2
  while s-- > i1+1
    b.unshift(@[s]) 
  b

console.log([0..10].between(0,5))
console.log(['a','b','c','d','e','f','g'].between('b','f'))


Array::excludeBetween = (o1,o2) ->
  if ((i1 = @indexOf(o1)) is -1) or ((i2 = @indexOf(o2)) is -1) or (i1 >= i2)
    null
  @splice(i1+1,i2-1)
  @

console.log(['a','b','c','d','e','f','g'].excludeBetween('b','f'))


Number::length = (shouldRound) ->
  Math[if shouldRound then 'round' else 'floor'](@).toString().replace('-','').length

console.log([1.812739182378,+1,1,-1,10,-10,100,-100].map( (n) -> n.length() ))
