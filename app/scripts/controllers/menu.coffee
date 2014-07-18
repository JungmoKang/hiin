'use strict'

angular.module('hiin').controller 'MenuCtrl', ($rootScope,$scope,Util,$window,socket,$state,$stateParams,$location,$ionicNavBarDelegate,$modal,$timeout) ->
  console.log 'called menu Ctrl'
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
    $scope.CloseHeaderMsg()
    $scope.msgHeaderShow = true
    $scope.headerMsg = msg
    $scope.msgHeaderClass = 'private_msg_push'
    $timeout (->
      $scope.CloseHeaderMsg()
    ), 2000
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
    if data.status is '0'
      msg = '<p> ' + data.sender_name + ' sended a message.' + '<p> Click to hi'
      ShowHeader(msg)
      $scope.user = data
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
  hi = (data) ->
    console.log 'got hi in menu'
    console.log data
    if $state.current.name is 'list.userlists'
      return
    msg = '<p> ' + data.fromName + ' Say HI' + '<p> Click to show profile'
    ShowHeader(msg)
    $scope.user = data
    $scope.headerClickAction = ShowProfile
  socket.on "message", message
  socket.on "groupMessage", groupMessage
  socket.on "hi", hi
  $scope.chatRoom = (user) ->
    if $scope.modalInstance? 
      $scope.modalInstance.close()
    history.pushState(null, null, '#/list/userlists')
    $state.go 'list.single',
      userId: user._id