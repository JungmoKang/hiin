'use strict'

angular.module('hiin').controller 'MenuCtrl', ($rootScope,$scope,Util,$window,socket,SocketClass,$state,$stateParams,$location,$ionicNavBarDelegate,$modal,$timeout,$filter) ->
  console.log 'called menu Ctrl'
  myInfo = JSON.parse($window.localStorage.getItem 'myInfo')
  $rootScope.onResume = ->
    console.log "On Resume"
    socket.emit "resume"
    console.log $state.current.name
    if $state.current.name is 'list.groupChat'
      console.log 'group chat'
      $scope.$broadcast("Resume", null)
      return
    if $state.current.name is 'list.single'
      console.log 'list single'
      $scope.$broadcast("Resume", null)
      return    
    return
  $rootScope.onPause = ->
    console.log "On Pause"
    socket.disconnect()
    return
  if typeof $rootScope.AddFlagPauseHandler  == 'undefined' || $rootScope.AddFlagPauseHandler is false
    document.addEventListener "resume", $rootScope.onResume, false
    document.addEventListener "pause", $rootScope.onPause, false
    $rootScope.AddFlagPauseHandler = true
  $rootScope.goBack = ->
    window.history.back()
  $scope.msgHeaderShow = false
  $scope.CloseHeaderMsg = ->
    $scope.msgHeaderShow = false
  ShowHeader = (msg) ->
    if $state.current.name is 'list.organizerSignUp'
      return
    $scope.CloseHeaderMsg()
    $scope.headerMsg = msg
    $scope.msgHeaderShow = true
    $timeout (->
      $scope.CloseHeaderMsg()
    ), 4000
    return
  ShowProfile = () ->
    $scope.CloseHeaderMsg()
    modalInstance = $modal.open(
      templateUrl: "views/dialog/user_card.html"
      scope: $scope
    )
    modalInstance.result.then ((selectedItem) ->
      $scope.modalInstance = null
      return
    ), ->
      $scope.modalInstance = null
      return
    $scope.modalInstance = modalInstance
  #개인 챗
  message = (data) ->
    console.log 'private message in menu'
    console.log data
    console.log('unreadcount:')
    socket.emit "unReadCount"
    if typeof $state.params.userId != 'undefined' and state.params.userId == data.sender
      return
    eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
    listKey = eventInfo.code + '_currentEventUserList'
    users = JSON.parse($window.localStorage.getItem listKey)
    user = $filter('getUserById')(users, data.sender)
    $scope.msgHeaderClass = 'private_msg_push'
    if user.status is '0' or user.status is '2'
      msg = '<p> ' + data.sender_name + ' has sent a message.' + 
      '<p> Click to say \'HI\' and join th chat.'
      ShowHeader(msg)
      $scope.user = user
      $scope.headerClickAction = ShowProfile
    else
      shortMsg = $filter('getShortSentence')(data.content, 30)
      msg = '<p> ' + data.sender_name + ' has sent a message.' + "<p>\'" + shortMsg + "\'"
      ShowHeader(msg)
      $scope.headerClickAction = ->
        $scope.CloseHeaderMsg()
        history.pushState(null, null, '#/list/userlists')
        $state.go 'list.single',
          userId: data.sender
  #그룹챗 나중에 지울거임
  groupMessage = (data) ->
    console.log 'group message in menu'
    console.log data
    socket.emit "unReadCountGroup"
    if $state.current.name is 'list.groupChat'
      return
    msg = '<p> GroupMessage: ' + data.content + '<p> Click to move'
    $scope.msgHeaderClass = 'private_msg_push'
    ShowHeader(msg)
    $scope.headerClickAction = ->
      $scope.CloseHeaderMsg()
      history.pushState(null, null, '#/list/userlists')
      $state.go 'list.groupChat'
  #전체공지
  notice = (data) ->
    console.log 'got notice'
    console.log data
    socket.emit "unReadCountNotice"
    if $state.current.name is 'list.notice'
      return
    if myInfo._id is data.from
      return
    msg = '<p>\'' + data.message + '\'<p>Click to check the detail of notice.'
    $scope.msgHeaderClass = 'notice_push'
    ShowHeader(msg)
    $scope.headerClickAction = ->
      $scope.CloseHeaderMsg()
    return
  MakeCurrentEventUserListOptionObj = ->
    console.log 'make event user list obj'
    socketMyInfo = new SocketClass.socketClass('currentEventUserList',null,100,false)
    socketMyInfo.onCallback = (data) ->
      console.log "menu currentEventUserList"
      eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
      listKey = eventInfo.code + '_currentEventUserList'
      console.log "listKey is " + listKey
      if data.length > 0
        sortedData = $filter('orderBy')(data,'rank')
        $window.localStorage.setItem listKey, JSON.stringify(sortedData)
      console.log data
      return
    return socketMyInfo
  SendEmitCurrentEventUserList = ->
    SocketClass.resSocket(MakeCurrentEventUserListOptionObj())
      .then (data) ->
        console.log 'socket got user list'
      , (status) ->
        console.log "error"
    return
  ###
  1. 유저가 추가되었을때
  2. 하이를 받았을때,
  3. 내가 하이를 했을때
  유저 정보를 갱신하여 로컬 스토리지에 저장한다.
  ###
  $scope.sayHi = (user) ->
    if user.status is '0' or user.status is '2'
      console.log 'sayhi'
      setTimeout () -> 
        socket.emit "hi" , {
          targetId : user._id
        }, 100000
      return
  #하이를 받았을때
  hi = (data) ->
    console.log 'got hi in menu'
    console.log data
    if $state.current.name is 'list.userlists'
      SendEmitCurrentEventUserList()
      return
    eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
    listKey = eventInfo.code + '_currentEventUserList'
    users = JSON.parse($window.localStorage.getItem listKey)
    user = $filter('getUserById')(users, data.from)
    subString = '.'
    if user.status is '0'
      subString = ' and say \'HI\' back.'
      user.status = "2"
    else
      user.status = "3"
    msg = '<p> ' + data.fromName + 'has sent \'HI\'' + '<p> Click to see his profile' + subString
    $scope.msgHeaderClass = 'hi_push'
    ShowHeader(msg)
    $scope.user = user
    $scope.headerClickAction = ShowProfile
    SendEmitCurrentEventUserList()
    return
  userListChange = (data) ->
    console.log 'userListChange in menu'
    console.log data
    SendEmitCurrentEventUserList()
    return
  hiMe = (data) ->
    console.log 'on hiMe in menu'
    SendEmitCurrentEventUserList()
    return
  pendingHi = (data) ->
    console.log 'on pendinghi in menu'
    console.log data.status
    SendEmitCurrentEventUserList()
    return
  socket.on "notice", notice
  socket.on "message", message
  socket.on "groupMessage", groupMessage
  socket.on "hi", hi
  socket.on "userListChange", userListChange
  socket.on "hiMe", hiMe
  socket.on "pendingHi", pendingHi
  $scope.chatRoom = (user) ->
    if $scope.modalInstance? 
      $scope.modalInstance.close()
    history.pushState(null, null, '#/list/userlists')
    $state.go 'list.single',
      userId: user._id
  $scope.DialogClose = ->
    $scope.modalInstance.close()
