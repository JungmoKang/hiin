'use strict'

angular.module('hiin').controller 'MenuCtrl', ($rootScope,$scope,Util,$window,socket,SocketClass,$state,$stateParams,$location,$ionicNavBarDelegate,$modal,$timeout,$filter) ->
  console.log 'called menu Ctrl'
  ###
  액티비티 갱신
  1. 하이 받았을때
  2. 하이할때
  3. 메세지 받았을때
  4. 유저가 추가되었을때
  ###
  myInfo = JSON.parse($window.localStorage.getItem 'myInfo')
  $window.localStorage.setItem "sleep", false
  $rootScope.onResume = ->
    console.log "On Resume"
    $window.localStorage.setItem "sleep", false
    socket.emit "resume"
    console.log $state.current.name
    switch $state.current.name
      when 'list.groupChat'
        console.log 'group chat'
        $scope.$broadcast("Resume", null)
      when 'list.single'
        console.log 'list single'
        $scope.$broadcast("Resume", null)
      when 'list.userlists'
        console.log 'list'
        $scope.$broadcast("Resume", null)
    return
  $rootScope.onPause = ->
    console.log "On Pause"
    $window.localStorage.setItem "sleep", true
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
    sleepFlg = $window.localStorage.getItem "sleep"
    console.log sleepFlg
    if sleepFlg is 'true'
      console.log 'dont show header'
      return
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
  GetUserById = (id) ->
    eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
    listKey = eventInfo.code + '_currentEventUserList'
    users = JSON.parse($window.localStorage.getItem listKey)
    user = $filter('getUserById')(users, id)
    return user
  #개인 챗
  message = (data) ->
    console.log 'private message in menu'
    console.log data
    socket.emit "unReadCount"
    $scope.$broadcast("update activity", data)
    if typeof $state.params.userId != 'undefined' and $state.params.userId == data.sender
      return
    user = GetUserById(data.sender)
    if user.unread is false
      SendEmitCurrentEventUserList()
    $scope.msgHeaderClass = 'private_msg_push'
    if user.status is '0' or user.status is '2'
      msg = '<p> ' + data.sender_name + ' has sent a message.' + 
      '<p> Click to say \'HI\' and join th chat.'
      ShowHeader(msg)
      $scope.user = user
      $scope.headerClickAction = ShowProfile
    else
      shortMsg = Util.trimStr(data.content, 30)
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
      console.dir data
      return
    return socketMyInfo
  SendEmitCurrentEventUserList = ->
    eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
    if eventInfo is null
      return
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
    console.log 'menu say hi'
    if user.status is '0' or user.status is '2'
      console.log 'sayhi'
      socket.emit "hi" , {
        targetId : user._id
      }
      if user.status is '2'
        eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
        socket.emit "readHi" , {
          partner : user._id
          code : eventInfo.code
        }
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
    $scope.$broadcast("update activity", data)
    return
  userListChange = (data) ->
    console.log 'userListChange in menu'
    console.log data
    SendEmitCurrentEventUserList()
    $scope.$broadcast("update activity", data)
    return
  hiMe = (data) ->
    console.log 'on hiMe in menu'
    SendEmitCurrentEventUserList()
    $scope.$broadcast("update activity", data)
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
    if user.unread == true
      console.log 'CancelRedPoint'
      user.unread = false
      SaveUsersToLocalStorage()
    history.pushState(null, null, '#/list/userlists')
    $state.go 'list.single',
      userId: user._id
  $scope.DialogClose = ->
    $scope.modalInstance.close()
  $scope.$on "pushed", (event,arg) ->
    console.log 'pushed menu'
    console.dir arg
    args = {}
    if $rootScope.deviceType is "android"
      args.type = arg.payload.type
      args.id = arg.payload.id
    else
      args = arg
    switch args.type
      when "personal"
        console.log "personal"
        #history.pushState(null, null, '#/list/userlists')
        user = GetUserById(args.id)
        if user.status is '0' or user.status is '2'
          $scope.user = user
          ShowProfile()
        else
          $scope.CloseHeaderMsg()
          history.pushState(null, null, '#/list/userlists')
          $state.go 'list.single',
            userId: args.id
      when "group"
        console.log "group"
        history.pushState(null, null, '#/list/userlists')
        $state.go 'list.groupChat'
      when "notice"
        console.log "notice"
        history.pushState(null, null, '#/list/userlists')
        $state.go 'list.notice'
      when "hi"
        console.log "hi"
