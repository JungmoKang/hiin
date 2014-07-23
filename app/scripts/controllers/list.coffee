'use strict'

angular.module('hiin').controller 'ListCtrl', ($route, $filter, $rootScope,$scope, $window, Util, socket, SocketClass,$modal, $state,$location,$ionicNavBarDelegate,$timeout) ->
  #init
  $rootScope.selectedItem = 2
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
    user.status = "2"
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
  socket.on "unReadCount", unReadCount
  socket.on "unReadCountGroup", unReadCountGroup
  socket.on "userListChange", userListChange
  socket.on "hi", hi
  socket.on "hiMe", hiMe
  socket.on "pendingHi", pendingHi
  # ↑
  $scope.chatRoom = (user) ->
    if $scope.modalInstance? 
      $scope.modalInstance.close()
    $location.url('/list/userlists/'+user._id)
  $scope.sayHi = (user) ->
    if user.status is '0' or user.status is '2'
      console.log 'sayhi'
      setTimeout () -> 
        socket.emit "hi" , {
          targetId : user._id
        }, 100000
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