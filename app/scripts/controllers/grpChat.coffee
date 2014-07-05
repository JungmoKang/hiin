'use strict'

angular.module("hiin").controller "grpChatCtrl", ($scope, $window, socket, Util,$location,$ionicScrollDelegate,$timeout) ->
  console.log 'grpChat'
  #group chat init
  $scope.input_mode = false
  $scope.imagePath = Util.serverUrl() + "/"
  if $window.localStorage?
    thisEvent = $window.localStorage.getItem "thisEvent"
    $scope.myInfo = JSON.parse($window.localStorage.getItem 'myInfo')
    console.log $scope.myInfo
  messageKey = thisEvent + '_groupMessage'
  $scope.roomName = "GROUP CHAT"
  if $window.localStorage.getItem messageKey
    $scope.messages =  JSON.parse($window.localStorage.getItem messageKey)
  else
    $scope.messages = []
  if $scope.messages.length > 0
    console.log '----unread----'
    console.log 'len:'+$scope.messages.length
    socket.emit 'loadMsgs', {
                              code: thisEvent
                              type: "group"
                              range: "unread"
                              lastMsgTime: $scope.messages[$scope.messages.length-1].created_at
    }
  else
    console.log '---first entered---'
    #first enter msg isert
  
  $scope.pullLoadMsg =->
    console.log '---pull load msg---'
    socket.emit 'loadMsgs', {
                              code: thisEvent
                              type: "group"
                              range: "pastThirty"
                              firstMsgTime: $scope.messages[0].created_at
    }


  socket.on 'loadMsgs', (data)->
    if data.message
      data.message.forEach (item)->
        if item.sender is $scope.myInfo._id
          item.sender_name = 'me'
        return
    if data.type is 'group' and data.range is 'all'
      console.log '---all---'
      $scope.messages = data.message
    else if data.type is 'group' and data.range is 'unread'
      console.log '---unread----'
      console.log data
      tempor = $scope.messages.concat data.message
      console.log tempor
      console.log 'tmper len:'+tempor.length
      $scope.messages = tempor
    else if data.type is 'group' and data.range is 'pastThirty'
      console.log '---pastthirty---'
      console.log data.message 
      console.log 'length:'+data.message.length
      tempor = data.message.reverse().concat $scope.messages
      console.log tempor
      console.log 'tmper len:'+tempor.length
      $scope.messages = tempor
      $scope.$broadcast('scroll.refreshComplete')
    $window.localStorage.setItem messageKey, JSON.stringify($scope.messages)

  $scope.data = {}
  $scope.data.message = ""
  $scope.amIOwner = false
  if window.localStorage['eventOwner'] == $scope.myInfo._id
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
    temp = $scope.messages
    len = temp.length
    console.log 'mlen:'+len
    if len > 30
      window.localStorage[messageKey]=JSON.stringify(temp.slice(len-30,temp.length))
    return  
  isIOS = ionic.Platform.isWebView() and ionic.Platform.isIOS()

  socket.on "groupMessage", (data) ->
    console.log "grp chat,groupMessage"
    if $scope.myInfo._id == data.sender
      data.sender_name = 'me'
    $scope.messages.push data
    $window.localStorage.setItem messageKey, JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
    return
  $scope.sendMessage =->
    time = new Date()
    if $scope.data.message == ""
      return
    if $scope.amIOwner is true and $scope.regular_msg_flg is false
      socket.emit "notice",{
        created_at: time
        message: $scope.data.message
        }
    else
      socket.emit "groupMessage",{
        created_at: time
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
    returr
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
