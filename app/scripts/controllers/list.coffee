'use strict'

angular.module('hiin').controller 'ListCtrl', ($route, $rootScope,$scope, $window, Util, socket, $modal, $state,$location,$ionicNavBarDelegate,$timeout) ->
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
  messageKey = thisEvent + '_groupMessage'
  if $window.localStorage.getItem messageKey
    $scope.messages =  JSON.parse($window.localStorage.getItem messageKey)
  else
    $scope.messages = []
  if $scope.messages.length > 0
    console.log '----unread----'
    console.log 'len:'+$scope.messages.length
    socket.emit 'unReadCountGroup', {
                              code: thisEvent
                              type: "group"
                              range: "unread"
                              lastMsgTime: $scope.messages[$scope.messages.length-1].created_at
    }
  else
    socket.emit 'unReadCountGroup', {
                              code: thisEvent
                              type: "group"
                              range: "all"
    }
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
  $scope.ShowPrivacyFreeDialog()
  socket.emit "currentEventUserList"
  socket.emit "unReadCount"
  $scope.users = []
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeListener("unReadCount", unReadCount)
    socket.removeListener("unReadCountGroup", unReadCountGroup)
    socket.removeListener("currentEventUserList", currentEventUserList)
    socket.removeListener("userListChange", userListChange)
    socket.removeListener("hi", hi)
    socket.removeListener("hiMe", hiMe)
    socket.removeListener("pendingHi", pendingHi)
    return
  # socket event ↓
  unReadCount = (data) ->
    console.log '--unread count---'
    console.log data
    $scope.unreadActivity = data.count
    return
  unReadCountGroup = (data) ->
    console.log '--unread count---'
    console.log data
    $scope.unreadGroup = data.count
    return
  currentEventUserList = (data) ->
    console.log "list currentEventUserList"
    $scope.users = data
    console.log data
    return
  userListChange = (data) ->
    console.log 'userListChange'
    console.log data
    socket.emit "currentEventUserList"
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
    socket.emit "currentEventUserList"
    return
  hiMe = (data) ->
    console.log 'on hiMe'
    socket.emit "currentEventUserList"
    return
  pendingHi = (data) ->
    console.log 'on pendinghi'
    console.log "list pedinghi"
    if data.status isnt "0"
      console.log('error':data.status)
      return
    socket.emit "currentEventUserList"
    return
  socket.on "unReadCount", unReadCount
  socket.on "unReadCountGroup", unReadCountGroup
  socket.on "currentEventUserList", currentEventUserList
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
