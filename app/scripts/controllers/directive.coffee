angular.module("hiin").directive "ngDisplayYou", ($window)->
  link: (scope, element, attrs) ->
    console.log attrs.sender
    if attrs.sender == 'me'
        element.show()
    else
        element.hide()

angular.module("hiin").directive "ngDot", ($window)->
  link: (scope, element, attrs) ->
    console.log attrs.read
    if (attrs.read == true)
       element.hide() 
    else
       element.show()
angular.module("hiin").directive "ngChatInput", ($timeout) ->
  restrict: "A"
  scope:
    returnClose: "="
    onReturn: "&"
    onFocus: "&"
    onBlur: "&"
  link: (scope, element, attr) ->
    element.bind "focus", (e) ->
      console.log 'focusss'
      if scope.onFocus
        window.scroll(0,0)
        $timeout -> 
          scope.onFocus()
          return
      return
    element.bind "blur", (e) ->
      console.log 'blur'
      console.log document.activeElement.tagName
      console.log attr
      console.log attr.clicksendstatus 
      if attr.clicksendstatus is "true"
        console.log('true')
        attr.clicksendstatus = false
        angular.element(":text").focus()
      else
        console.log('false')
        if scope.onBlur
          $timeout ->
          scope.onBlur()
          return
      return
    element.bind "keydown", (e) ->
      console.log 'keydown'
      if e.which is 13
        console.log 'entered'
        element[0].blur()  if scope.returnClose
        if scope.onReturn
          $timeout ->
            scope.onReturn()
            return
      return
    return
#accept : 3, request:1, pending:2, else :0
angular.module("hiin").directive "ngHiBtn", ()->
  link: (scope, element, attrs) ->
    console.log attrs.histatus
    if attrs.histatus is '0'
      console.log('btn status = hi')
      element.addClass 'btn-front'
    else if attrs.histatus is '1' or attrs.histatus is '3' 
      console.log ('btn Status = in')
      element.addClass 'btn-back'
angular.module("hiin").directive "ngInBtn", ()->
  link: (scope, element, attrs) ->
    console.log attrs.histatus
    if attrs.histatus is '0' or attrs.histatus is '2' 
      console.log('btn status = hi')
      element.addClass 'btn-back'
    else
      console.log ('btn Status = in')
      element.addClass 'btn-front'
angular.module("hiin").directive "ngFlipBtn", ()->
  link: (scope, element, attrs) ->
    console.log attrs.histatus
    if attrs.histatus is '0' 
      element.bind 'click', ()->
        element.addClass 'btn-flip'
        console.log('addclass')
    else if attrs.histatus is '2'
      element.bind 'click', ()->
        element.addClass 'btn-flip'
        console.log('addclass')
    else
      console.log ('btn Status = in')
angular.module("hiin").directive "ngProfileImage", ($compile,Util)->
  link: (scope,element, attrs) ->
    console.log 'ngProfileImage　attrs'
    attrs.$observe 'source', (val) ->
      newVal = val
      if val.indexOf('http') < 0
        newVal = Util.serverUrl() + "/" + val
      attrs.$set('src', newVal)
      attrs.$set('ng-click', 'alert("test")')
