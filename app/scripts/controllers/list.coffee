'use strict'

angular.module('hiin').controller 'ListCtrl', ($route, $filter, $rootScope,$scope, $window, Util, socket, SocketClass,$modal, $state,$location,$ionicNavBarDelegate,$timeout) ->
  #init
  $rootScope.selectedItem = 2
  MakeMyInfoOptionObj = () ->
    socketMyInfo = new SocketClass.socketClass('myInfo',null,1500,true)
    socketMyInfo.onCallback = (data) ->
      console.log "list myInfo"
      console.log data
      $window.localStorage.setItem 'myInfo', JSON.stringify(data)
      $scope.myId = new Array()
      $scope.myId.author = JSON.parse($window.localStorage.getItem 'myInfo')._id
      return
    return socketMyInfo
  SendEmitMyInfo = () ->
    SocketClass.resSocket(MakeMyInfoOptionObj())
      .then (data) ->
        console.log 'socket got myInfo'
      , (status) ->
        console.log "error"
        alert 'error get my info'
  myInfo = JSON.parse($window.localStorage.getItem 'myInfo')
  if !myInfo?
    SendEmitMyInfo()
  MakeNoticeObj = () ->
    socketMyInfo = new SocketClass.socketClass('unReadCountNotice',null,0,false)
    socketMyInfo.onCallback = (data) ->
      console.log "menu unReadCountNotice"
      console.log data
      if data.count > 0
        $rootScope.noticeFlg = true
      return
    return socketMyInfo
  if ($window.localStorage.getItem 'thisEventOwner') isnt 'true'
    SocketClass.resSocket(MakeNoticeObj())
      .then (data) ->
        console.log 'socket got notice'
      , (status) ->
        console.log "error"
  ionic.DomUtil.ready ->
    $ionicNavBarDelegate.showBackButton(false)
  if $window.localStorage?
    eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
    if eventInfo?
      thisEvent = eventInfo.code
      $scope.eventName = eventInfo.name
    else
      $scope.back = ->
        console.log 'back'
        $scope.modal.hide()
        $scope.modal.remove()
        $window.history.back()
      $scope.message = '<p> You have not entered an event. 
      <p>Please go back 
      <p>and 
      <p>type passcode to join an event.'
      Util.ShowModal($scope,'no_event')
      return
    console.log 'list this event is ' + thisEvent
  $scope.ShowPrivacyFreeDialog = ->
    #표시한 적이 있는가 없는가를 판단해서, 없을 경우 표시
    if $window.localStorage.getItem 'flg_show_privacy_dialog'
      return
    modalInstance = $modal.open(
      templateUrl: "views/dialog/privacy_free.html"
      scope: $scope
    )
    modalInstance.result.then ((selectedItem) ->
      $scope.modalInstance = null
      return
    ), ->
      $scope.modalInstance = null
      return
    $scope.modalInstance = modalInstance
    $window.localStorage.setItem 'flg_show_privacy_dialog', true
  $scope.DialogClose = ->
    $scope.modalInstance.close()
  $scope.ShowPrivacyFreeDialog()
  SaveUsersToLocalStorage = ->
    $window.localStorage.setItem listKey, JSON.stringify($scope.users)
  MakeCurrentEventUserListOptionObj = ->
    socketMyInfo = new SocketClass.socketClass('currentEventUserList',null,100,true)
    socketMyInfo.onCallback = (data) ->
      console.log data
      console.log "list currentEventUserList"
      console.log 'listKey is ' + listKey
      if data.length > 0
        sortedData = $filter('orderBy')(data,'rank')
        $window.localStorage.setItem listKey, JSON.stringify(sortedData)
        $scope.users = sortedData
        console.dir $scope.users
      return
    return socketMyInfo
  SendEmitCurrentEventUserList = ->
    SocketClass.resSocket(MakeCurrentEventUserListOptionObj())
      .then (data) ->
        console.log 'socket got user list'
      , (status) ->
        console.log "error"
    return
  listKey = thisEvent + '_currentEventUserList'
  tempList = $window.localStorage.getItem listKey
  if tempList && tempList isnt '[]'
    $scope.users = JSON.parse(tempList)
    $scope.users = $filter('orderBy')($scope.users,'rank')
    console.log "Get Users from local Storage"
    console.dir $scope.users
  else
    $scope.users = []
    SendEmitCurrentEventUserList()
  socket.emit "unReadCount"
  socket.emit "unReadCountGroup"
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeListener("unReadCount", unReadCount)
    socket.removeListener("unReadCountGroup", unReadCountGroup)
    socket.removeListener("userListChange", userListChange)
    socket.removeListener("hi", hi)
    socket.removeListener("hiMe", hiMe)
    socket.removeListener("pendingHi", pendingHi)
    socket.removeListener("message", message)
    return
  # socket event ↓
  unReadCount = (data) ->
    console.log '-######-unread count--#####-'
    console.log data
    $scope.unreadActivity = data.count
    return
  unReadCountGroup = (data) ->
    console.log '-########-unread count for group--#######-'
    console.log data
    $scope.unreadGroup = data.count
    return
  userListChange = (data) ->
    console.log 'userListChange'
    console.log data
    return
  hi = (data) ->
    console.log 'on hi'
    $scope.sendHi = data.fromName
    modalInstance = $modal.open(
      templateUrl: "views/list/hi_modal.html"
      scope: $scope
    )
    modalInstance.result.then ((selectedItem) ->
      return
    ), ->
      $scope.modalInstance = null
      return
    $scope.modalInstance = modalInstance
    user = $filter('getUserById')($scope.users, data.from)
    if user.status is "0"
      user.status = "2"
      user.unread = true
      SaveUsersToLocalStorage()
    # 하이 받았을때 리스트가 새로 변경되는게 보기 이상함..그래서 주석처리
    #SendEmitCurrentEventUserList()
    return
  hiMe = (data) ->
    console.log 'on hiMe'
    # 하이 받았을때 리스트가 새로 변경되는게 보기 이상함..그래서 주석처리
    # 대신에, 클라이언트에서 변경
    return
  pendingHi = (data) ->
    console.log 'on pendinghi'
    console.log "list pedinghi"
    console.log data.status
    if data.status isnt "0"
      console.log('error':data.status)
      return
    #SendEmitCurrentEventUserList()
    return
  message = (data) ->
    console.log 'private message in list'
    console.log data
    user = $filter('getUserById')($scope.users, data.sender)
    if user is null
      return
    if user.unread is false
      user.unread = true
      SaveUsersToLocalStorage()
    return
  socket.on "unReadCount", unReadCount
  socket.on "unReadCountGroup", unReadCountGroup
  socket.on "userListChange", userListChange
  socket.on "hi", hi
  socket.on "hiMe", hiMe
  socket.on "pendingHi", pendingHi
  socket.on "message", message
  # ↑
  $scope.chatRoom = (user) ->
    if $scope.modalInstance? 
      $scope.modalInstance.close()
    if user.unread == true
      console.log 'CancelRedPoint'
      user.unread = false
      SaveUsersToLocalStorage()
    $location.url('/list/userlists/'+user._id)
  $scope.sayHi = (user) ->
    console.log 'list say hi'
    if user.status is '0' or user.status is '2'
      console.log 'sayhi'
      socket.emit "hi" , {
        targetId : user._id
      }
      if user.status is '2'
        socket.emit "readHi" , {
          partner : user._id
          code : thisEvent
        }
    if user.unread == true
      console.log 'CancelRedPoint'
      user.unread = false
      SaveUsersToLocalStorage()
    return
  $scope.activity = ->
  	$location.url('/list/activity')
  $scope.groupChat = ->
    $location.url('/list/groupChat')
  $scope.info = ->
    $location.url('/list/eventInfo')
  $scope.imagePath = Util.serverUrl() + "/"
  #프로필 표시 나중에 util에 넣어서 다른 화면에서도 쓸 수 있게 해야함
  $scope.ShowProfile = (user) ->
    console.log user
    $scope.user = user
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
  $scope.CloseDialog = ->
    $scope.modalInstance.close()
  $scope.GotoNotice = ->
    $state.go 'list.notice'
  $scope.$on "Resume", (event,args) ->
    console.log 'list resume'
    console.log args
    SendEmitCurrentEventUserList()