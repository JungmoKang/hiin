'use strict'

angular.module('hiin').controller 'MenuCtrl', ($rootScope,$scope,Util,$window,socket,SocketClass,$state,$stateParams,$location,$ionicNavBarDelegate,$modal,$timeout,$filter) ->
  console.log 'called menu Ctrl'
  myInfo = JSON.parse($window.localStorage.getItem 'myInfo')
  $rootScope.onResume = ->
    console.log "On Resume"
    socket.emit "resume"
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
    $scope.msgHeaderShow = true
    $scope.headerMsg = msg
    $scope.msgHeaderClass = 'private_msg_push'
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
  message = (data) ->
    console.log 'private message in menu'
    console.log data
    if typeof $state.params.userId != 'undefined' and state.params.userId == data.sender
      return
    eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
    listKey = eventInfo.code + '_currentEventUserList'
    users = JSON.parse($window.localStorage.getItem listKey)
    user = $filter('getUserById')(users, data.sender)
    if user.status is '0' or user.status is '2'
      msg = '<p> ' + data.sender_name + ' sended a message.' + '<p> Click to hi'
      ShowHeader(msg)
      $scope.user = user
      $scope.headerClickAction = ShowProfile
    else
      msg = '<p> ' + data.sender_name + ' sended:' + data.content + '<p> Click to move'
      ShowHeader(msg)
      $scope.headerClickAction = ->
        $scope.CloseHeaderMsg()
        history.pushState(null, null, '#/list/userlists')
        $state.go 'list.single',
          userId: data.sender
  groupMessage = (data) ->
    console.log 'group message in menu'
    console.log data
    if $state.current.name is 'list.groupChat'
      return
    msg = '<p> GroupMessage: ' + data.content + '<p> Click to move'
    ShowHeader(msg)
    $scope.headerClickAction = ->
      $scope.CloseHeaderMsg()
      history.pushState(null, null, '#/list/userlists')
      $state.go 'list.groupChat'
  notice = (data) ->
    console.log 'got notice'
    console.log data
    if myInfo._id is data.from
      return
    msg = '<p> NOTICE: ' + data.message + '<p> Click to move'
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
      $window.localStorage.setItem listKey, JSON.stringify(data)
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
  hi = (data) ->
    console.log 'got hi in menu'
    console.log data
    if $state.current.name is 'list.userlists'
      SendEmitCurrentEventUserList()
      return
    msg = '<p> ' + data.fromName + ' Say HI' + '<p> Click to show profile'
    ShowHeader(msg)
    eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
    listKey = eventInfo.code + '_currentEventUserList'
    users = JSON.parse($window.localStorage.getItem listKey)
    user = $filter('getUserById')(users, data.from)
    user.status = "2"
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