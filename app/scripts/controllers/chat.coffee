'use strict'

angular.module("hiin").controller "chatCtrl", ($rootScope,$ionicSideMenuDelegate, $scope, $filter,$window,socket, Util,$stateParams,$ionicScrollDelegate,$timeout) ->
  console.log('chat')
  console.dir($stateParams)
  #init
  partnerId = $stateParams.userId
  #for retention of keyboard up
  $scope.clickSendStatus = false
  $ionicSideMenuDelegate.canDragContent(false)
  if $window.localStorage?
    eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
    thisEvent = eventInfo.code
    $scope.myInfo = JSON.parse($window.localStorage.getItem 'myInfo')
    listKey = thisEvent + '_currentEventUserList'
    users = JSON.parse($window.localStorage.getItem listKey)
    console.log users
    $scope.user = $filter('getUserById')(users, partnerId)
    $scope.partner = $scope.user.firstName
    $scope.roomName = "CHAT WITH " + $scope.user.firstName
  messageKey = thisEvent + '_' + partnerId
  $scope.scrollDelegate = null
  #기본적으로 개인 메세지 창은 나가기 개념이 없음. 즉, 대화가 로컬에 없으면 처음 대화하므로 상대방 대화를 모두 긁어옴
  if $window.localStorage.getItem messageKey
    $scope.messages =  JSON.parse($window.localStorage.getItem messageKey)
  else
    $scope.messages = []
  SendLoadMsgs = ->
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
  SendLoadMsgs()
  $scope.pullLoadMsg =->
    console.log '---pull load msg---'
    if $scope.messages.length > 0
      lastTime = $scope.messages[0].created_at
    else
      lastTime = new Date()
    socket.emit 'loadMsgs', {
                              code: thisEvent
                              type: "group"
                              range: "pastThirty"
                              firstMsgTime: lastTime
    }
  # socket event ↓
  loadMsgs = (data)->
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
      console.log $("#messageList")[0].scrollHeight
      prevHeight = $("#messageList")[0].scrollHeight 
      $scope.messages = tempor
      $scope.$apply()
      console.log $("#messageList")[0].scrollHeight
      nextHeight = $("#messageList")[0].scrollHeight
      $scope.$broadcast('scroll.refreshComplete')
      scrollTo = nextHeight - prevHeight -
      $scope.scrollDelegate.scrollTo(0,scrollTo,false)
    $scope.$apply()
    $window.localStorage.setItem messageKey, JSON.stringify($scope.messages)
    $ionicScrollDelegate.scrollBottom()
    return
  message = (data) ->
    console.log 'ms'
    console.log data
    if data.status < 0
      return
    if data.sender isnt $stateParams.userId
      return
    #read function here later
    $scope.messages.push data
    $window.localStorage.setItem messageKey, JSON.stringify($scope.messages)
    $scope.newMsg = null
    socket.emit "read",{
      msgId: data._id
    }
    if $scope.bottom is false
      $scope.newMsg = data
      $scope.newMsg.msg = Util.trimStr(data.content, 30)
    else
      $ionicScrollDelegate.scrollBottom()
    return
  socket.on 'loadMsgs', loadMsgs
  socket.on "message", message
  $scope.data = {}
  $scope.data.message = ""
  keyboardShowEvent = (e) ->
    console.log "Keyboard height is: " + e.keyboardHeight
    if document.activeElement.tagName is "BODY"
      cordova.plugins.Keyboard.close()
      return
    window.scroll(0,0)
    if isIOS
      $scope.data.keyboardHeight = e.keyboardHeight
    $timeout (->
      $ionicScrollDelegate.scrollBottom true
      return
    ), 200
    return
  keyboardHideEvent = (e) ->
    console.log "Keyboard close"
    $scope.data.keyboardHeight = 0
    $ionicScrollDelegate.resize()
    return    
  window.addEventListener "native.keyboardshow", keyboardShowEvent, false
  window.addEventListener "native.keyboardhide", keyboardHideEvent, false
  #채팅창에서만 키보드 헤더를 표시하지 않음
  ionic.DomUtil.ready ->
    if window.cordova
      cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
    $("body").height "100%"
    $scope.bodyHeight = $("body").height()
    #스크롤 이벤트 등록
    $scope.bottom = true
    $scope.scrollDelegate = $ionicScrollDelegate.$getByHandle('myScroll')
    $scope.scrollDelegate.getScrollView().onScroll = ->
      if ($scope.scrollDelegate.getScrollView().__maxScrollTop - $scope.scrollDelegate.getScrollPosition().top) < 30
        $scope.bottom = true
        if $scope.newMsg isnt null 
          $scope.newMsg = null
          $ionicScrollDelegate.scrollBottom()
      else
        $scope.bottom = false
  $scope.$on "$destroy", (event) ->
    if window.cordova
      cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(false) && cordova.plugins.Keyboard.close()
    if $rootScope.deviceType is "android"
      $("body").height($scope.bodyHeight)
    $ionicSideMenuDelegate.canDragContent(true)
    #등록된 이벤트 삭제
    socket.removeListener("loadMsgs",loadMsgs)
    socket.removeListener("message",message)
    window.removeEventListener "native.keyboardshow", keyboardShowEvent, false
    window.removeEventListener "native.keyboardhide", keyboardHideEvent, false
    temp = $scope.messages
    len = temp.length
    console.log 'mlen:'+len
    if len > 30
      window.localStorage[messageKey]=JSON.stringify(temp.slice(len-30,temp.length))  
  isIOS = ionic.Platform.isWebView() and ionic.Platform.isIOS()
  $scope.sendMessage =->
  	if $scope.data.message == ""
      return
    time = new Date()
    #$scope.clickSendStatus = true
    angular.element(':text').attr('clicksendstatus','true')
    socket.emit "message",{
      created_at: time
  		targetId: $stateParams.userId
  		message: $scope.data.message
  	}
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
    angular.element(':text').attr('clicksendstatus',false)
    if $rootScope.deviceType is 'web' and $rootScope.browser is 'ios'
      $("body").height ($(window).height()-216)
      $scope.ScrollToBottom()
  $scope.inputDown = ->
    console.log 'inputDown'
    if $rootScope.deviceType is 'web' and $rootScope.browser is 'ios'
      $("body").height "100%"
      $scope.ScrollToBottom()
    return
  $scope.ShowProfile = (sender) ->
    $rootScope.ShowProfileImage($scope.user)
    return
  $scope.ScrollToBottom = ->
    $ionicScrollDelegate.scrollBottom()
  $scope.dateChanged = (msg_id) -> 
    if $scope.messages.length > 0 and msg_id > 0
      bmd = new Date($scope.messages[msg_id - 1].created_at)
      cmd = new Date($scope.messages[msg_id].created_at)
      date_changed = bmd.getYear() != cmd.getYear() or bmd.getMonth() != cmd.getMonth() or bmd.getDate() != cmd.getDate()
      return date_changed
    else
      return msg_id == 0
  $scope.$on "back", (event,args) ->
    $scope.data.keyboardHeight = 0
    $ionicScrollDelegate.resize()
  $scope.$on "Resume", (event,args) ->
    console.log 'single chat resume'
    console.log args
    SendLoadMsgs()
