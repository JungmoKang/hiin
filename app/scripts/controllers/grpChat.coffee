'use strict'

angular.module("hiin").controller "grpChatCtrl", ($scope, $window, socket, Util,$location,$ionicScrollDelegate,$timeout) ->
  console.log 'grpChat'

  #group chat init
  $scope.input_mode = false
  $scope.imagePath = Util.serverUrl() + "/"
  $scope.myId = window.localStorage['myId']
  thisEvent = window.localStorage['thisEvent']
  messageKey = thisEvent + '_groupMessage'
  $scope.roomName = "GROUP CHAT"
  messages = window.localStorage[messageKey] || []
  if messages.length > 0
    $scope.messages = JSON.parse(messages)
  else
    $scope.messages = messages
  $scope.data = {}
  $scope.data.message = ""
  $scope.amIOwner = false
  if window.localStorage['eventOwner'] == $scope.myId
    $scope.amIOwner = true
    $scope.regular_msg_flg = false
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
    if $scope.myId == data.sender
      data.sender_name = 'me'
    $scope.messages.push data
    window.localStorage[messageKey] = JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
    return
  $scope.sendMessage =->
    if $scope.data.message == ""
      return
    if $scope.regular_msg_flg is true
      socket.emit "groupMessage",{
        message: $scope.data.message
        }
    else
      socket.emit "notice",{
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
  $scope.toggleOwnerMsg = ->
    $scope.regular_msg_flg = !$scope.regular_msg_flg
    if $scope.regular_msg_flg is true
      $scope.popupMessage = "Send as a regular chat message"
    else
      $scope.popupMessage = "Send as a notice to the group"
    $scope.showingMsg = true
    if $scope.timer?
      $timeout.cancel($scope.timer)
    $scope.timer = $timeout (->
      $scope.showingMsg = false
      return
    ), 2000
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
    console.log attrs.user
    if attrs.user == 'me'
      element.addClass 'chat-balloon-me'
    else
      element.addClass 'chat-balloon-you'
