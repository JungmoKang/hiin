'use strict';

angular.module("filters", [])
.filter "gender", ->
  (input) ->
    (if input == '1' then "Female" else "Male")
.filter "getUserById", ->
  (input, id) ->
    i = 0
    len = input.length
    while i < len
      return input[i]  if input[i]._id is id
      i++
    null
.filter 'profileImage', (Util) ->
  (input) ->
    newVal = input  
    if input.indexOf('http') < 0
      newVal = Util.serverUrl() + "/" + newVal
    return newVal
.filter "toShortSentence", (Util) ->
  (input, count) ->
    console.log input
    console.log count
    return Util.trimStr(input,count)