'use strict'

angular.module("hiin").controller "chatCtrl", ($scope, $window,socket, Util,$stateParams,$ionicScrollDelegate,$timeout) ->
  console.log('chat')
  console.dir($stateParams)

  #init
  partnerId = $stateParams.userId
  thisEvent = window.localStorage['thisEvent']
  $scope.myId = window.localStorage['myId']
  messageKey = thisEvent + '_' + partnerId
  #기본적으로 개인 메세지 창은 나가기 개념이 없음. 즉, 대화가 로컬에 없으면 처음 대화하므로 상대방 대화를 모두 긁어옴
  messages = window.localStorage[messageKey] || []
  if messages.length > 0
    $scope.messages = JSON.parse(messages)
    socket.emit 'loadMsgs', {
                              code: thisEvent
                              partner: partnerId
                              type: "personal"
                              range: "unread"
    }
  else
    socket.emit 'loadMsgs', { 
                              code: thisEvent
                              partner: partnerId
                              type: "personal"
                              range: "all"
    }
  
  $scope.pullLoadMsg =->
    socket.emit 'loadMsgs', {
                              code: thisEvent
                              partner: partnerId
                              type: "personal"
                              range: "all"
    }


  socket.on 'loadMsgs', (data)->
    data.message.forEach (item)->
      if item.sender is $scope.myId
        item.sender_name = 'me'
    if data.type is 'personal' and data.range is 'all'
      $scope.messages = data.message
      window.localStorage[messageKey] = JSON.stringify($scope.messages)

  #상대방의 정보 습득
  socket.emit "getUserInfo",{
      targetId: $stateParams.userId
    }
  $scope.data = {}
  $scope.data.message = ""
  #초기에 키보드가 표시되는 것을 방지하기 위한 플래그
  window.addEventListener "native.keyboardshow", (e) ->
    console.log "Keyboard height is: " + e.keyboardHeight
    if $scope.input_mode isnt true
      cordova.plugins.Keyboard.close()
      $scope.input_mode = true
    return
  window.addEventListener "native.keyboardhide", (e) ->
    console.log "Keyboard close"
    return
  #채팅창에서만 키보드 헤더를 표시하지 않음
  ionic.DomUtil.ready ->
    if window.cordova
      cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
  $scope.$on "$destroy", (event) ->
    if window.cordova
      cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(false) && cordova.plugins.Keyboard.close()
    socket.removeAllListeners()
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
    window.localStorage[messageKey] = JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()

  $scope.sendMessage =->
  	if $scope.data.message == ""
      return
    socket.emit "message",{
  		targetId: $stateParams.userId
  		message: $scope.data.message
  	}
    #내 사진은 표시 안
  	$scope.messages.push
        sender_name: 'me' 
        content: $scope.data.message
    $scope.data.message = ""
    window.localStorage[messageKey] = JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
  return
  $scope.inputUp = ->
    console.log 'inputUp'
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
  return
###
  w = angular.element($window)
  $scope.getHeight = ->
    w.height()
  $scope.$watch $scope.getHeight, (newValue, oldValue) ->
    $scope.windowHeight = newValue
    $scope.style = ->
      height: newValue + "px"
    return
  w.bind "resize", ->
    $scope.$apply()
    return
###
  
