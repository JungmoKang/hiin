'use strict';

angular.module("filters", [])
.filter "gender", ->
  (input) ->
    (if input == '1' then "Female" else "Male")
.filter "getUserById", ->
  (input, id) ->
    i = 0
    if input is null
      return null
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
.filter 'noHTML', ->
  (text) -> text.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/&/, '&amp;') if text?
.filter "replaceLink", ($sce)->
  (text) ->
    return $sce.trustAsHtml(if text? then text.replace(/(http:\/\/[\x21-\x7e]+)/gi, "<a href='$1'>$1</a>") else '')