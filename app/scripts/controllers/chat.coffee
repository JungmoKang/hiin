'use strict'

angular.module("hiin").controller "chatCtrl", ($scope, $window,socket, Util,$stateParams,$ionicScrollDelegate,$timeout) ->
  console.log('chat')
  console.dir($stateParams)
  #init
  partnerId = $stateParams.userId
  if $window.localStorage?
    eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
    thisEvent = eventInfo.code
    $scope.myInfo = JSON.parse($window.localStorage.getItem 'myInfo')
  messageKey = thisEvent + '_' + partnerId
  #기본적으로 개인 메세지 창은 나가기 개념이 없음. 즉, 대화가 로컬에 없으면 처음 대화하므로 상대방 대화를 모두 긁어옴
  if $window.localStorage.getItem messageKey
    $scope.messages =  JSON.parse($window.localStorage.getItem messageKey)
  else
    $scope.messages = []
  if $scope.messages.length > 0
    console.log '----unread----'
    console.log 'len:'+$scope.messages.length
    socket.emit 'loadMsgs', {
                              code: thisEvent
                              partner: partnerId
                              type: "personal"
                              range: "unread"
                              lastMsgTime: $scope.messages[$scope.messages.length-1].created_at
    }
  else
    console.log '---call all---'
    socket.emit 'loadMsgs', { 
                              code: thisEvent
                              partner: partnerId
                              type: "personal"
                              range: "all"
    }
  
  $scope.pullLoadMsg =->
    console.log '---pull load msg---'
    socket.emit 'loadMsgs', {
                              code: thisEvent
                              partner: partnerId
                              type: "personal"
                              range: "pastThirty"
                              firstMsgTime: $scope.messages[0].created_at
    }


  socket.on 'loadMsgs', (data)->
    if data.message
      data.message.forEach (item)->
        if item.sender is $scope.myInfo._id
          item.sender_name = 'me'
        return
    if data.type is 'personal' and data.range is 'all'
      console.log '---all---'
      $scope.messages = data.message
    else if data.type is 'personal' and data.range is 'unread'
      console.log '---unread----'
      console.log data
      tempor = $scope.messages.concat data.message
      console.log tempor
      console.log 'tmper len:'+tempor.length
      $scope.messages = tempor
    else if data.type is 'personal' and data.range is 'pastThirty'
      console.log '---else---'
      tempor = data.message.reverse().concat $scope.messages
      console.log tempor
      console.log 'tmper len:'+tempor.length
      $scope.messages = tempor
      $scope.$broadcast('scroll.refreshComplete')
    $scope.$apply()
    $window.localStorage.setItem messageKey, JSON.stringify($scope.messages)
  #상대방의 정보 습득
  socket.emit "getUserInfo",{
      targetId: $stateParams.userId
    }
  $scope.data = {}
  $scope.data.message = ""
  window.addEventListener "native.keyboardshow", (e) ->
    console.log "Keyboard height is: " + e.keyboardHeight
    if document.activeElement.tagName is "BODY"
      cordova.plugins.Keyboard.close()
      return
    window.scroll(0,0)
    $scope.data.keyboardHeight = e.keyboardHeight
    $timeout (->
      $ionicScrollDelegate.scrollBottom true
      return
    ), 200
    return
  window.addEventListener "native.keyboardhide", (e) ->
    console.log "Keyboard close"
    $scope.data.keyboardHeight = 0
    $ionicScrollDelegate.resize()
    return
  #채팅창에서만 키보드 헤더를 표시하지 않음
  ionic.DomUtil.ready ->
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
  socket.on "getUserInfo", (data) ->
    console.log "chat,getUserInfo"
    $scope.opponent = data
    $scope.partner = data.firstName
    $scope.roomName = "CHAT WITH " + data.firstName
  socket.on "message", (data) ->
    console.log 'ms'
    console.log data
    if data.status < 0
      return
    if data.sender isnt $stateParams.userId
      return
    #read function here later
    $scope.messages.push data
    $window.localStorage.setItem messageKey, JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
  $scope.sendMessage =->
  	if $scope.data.message == ""
      return
    time = new Date()
    socket.emit "message",{
      created_at: time
  		targetId: $stateParams.userId
  		message: $scope.data.message
  	}
    #내 사진은 표시 안
  	$scope.messages.push
      sender_name: 'me' 
      content: $scope.data.message
      created_at: time
      thumbnailUrl: $scope.myInfo.thumbnailUrl
    $scope.data.message = ""
    $window.localStorage.setItem messageKey, JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
  $scope.inputUp = ->
    console.log 'inputUp'
  $scope.inputDown = ->
    console.log 'inputDown'
    return
