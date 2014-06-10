'use strict'

angular.module("hiin").controller "grpChatCtrl", ($scope, $window, socket, Util,$location,$ionicScrollDelegate,$timeout) ->
  console.log 'grpChat'

  #group chat init
  $scope.input_mode = false
  $scope.imagePath = Util.serverUrl() + "/"
  myId = window.localStorage['myId']
  thisEvent = window.localStorage['thisEvent']
  messageKey = thisEvent + '_groupMessage'
  $scope.roomName = "GROUP CHAT"
  messages = window.localStorage[messageKey] || []
  if messages.length > 0
    $scope.messages = JSON.parse(messages)
  else
    $scope.messages = messages

  #초기에 키보드가 표시되는 것을 방지하기 위한 플래그
  window.addEventListener "native.keyboardshow", (e) ->
    console.log "Keyboard height is: " + e.keyboardHeight
    if $scope.input_mode isnt true
      cordova.plugins.Keyboard.close()
    return
  window.addEventListener "native.keyboardhide", (e) ->
    console.log "Keyboard close"
    $scope.input_mode = true
    return
  #채팅창에서만 키보드 헤더를 표시하지 않음
  ionic.DomUtil.ready ->
    console.log 'ready'
    if window.cordova
      cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
  $scope.$on "$destroy", (event) ->
    if window.cordova
      cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(false) && cordova.plugins.Keyboard.close()
    socket.removeAllListeners()
    return  
  isIOS = ionic.Platform.isWebView() and ionic.Platform.isIOS()

  socket.on "groupMessage", (data) ->
    console.log "grp chat,groupMessage"
    whosMessage = ""
    if myId == data._id
      whosMessage = 'me'
    else
      whosMessage = data.fromName
    $scope.messages.push
      user: whosMessage
      text: data.message
      thumbnailUrl: data.thumbnailUrl
      regTime: data.regTime
      _id: data._id
    socket.emit "read",{
      msgId: data.msgId
      }
    window.localStorage[messageKey] = JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
    return
  $scope.sendMessage =->
    socket.emit "groupMessage",{
      message: $scope.data.message
      }
    $scope.data.message = ""
  $scope.inputUp = ->
    console.log 'inputUp'
    window.scroll(0,0)
    $scope.data.keyboardHeight = 216  if isIOS
    $timeout (->
      $ionicScrollDelegate.scrollBottom true
      return
    ), 300
    return
  $scope.inputDown = ->
    console.log 'inputDown'
    $scope.data.keyboardHeight = 0  if isIOS
    $ionicScrollDelegate.resize()
    return
  $scope.data = {}
  return
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
      if scope.onBlur
        $timeout ->
          scope.onBlur()
          return
      return
    element.bind "keydown", (e) ->
      console.log e
      if e.which is 13
        console.log 'entered'
        element[0].blur()  if scope.returnClose
        if scope.onReturn
          $timeout ->
            scope.onReturn()
            return
      return
    return
angular.module("hiin").directive "ngChatBalloon", ($window)->
  link: (scope, element, attrs) ->
    console.log 'directive'
    console.log attrs.user
    if attrs.user == 'me'
      element.addClass 'chat-balloon-me'
    else
      element.addClass 'chat-balloon-you'