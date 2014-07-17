'use strict'

angular.module('hiin').controller 'MenuCtrl', ($rootScope,$scope,Util,$window,socket,$state,$stateParams,$location,$ionicNavBarDelegate,$modal) ->
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
  message = (data) ->
    console.log 'private message in menu'
    console.log data
    if typeof $state.params.userId != 'undefined' and state.params.userId == data.sender
      return
    $scope.msgHeaderShow = true
    $scope.headerMsg = '<p> ' + data.sender_name + ' sended:' + data.content + '<p> Click to move'
    $scope.msgHeaderClass = 'private_msg_push'
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
    $scope.msgHeaderShow = true
    $scope.headerMsg = '<p> GroupMessage: ' + data.content + '<p> Click to move'
    $scope.msgHeaderClass = 'private_msg_push'
    $scope.headerClickAction = ->
      $scope.CloseHeaderMsg()
      history.pushState(null, null, '#/list/userlists')
      $state.go 'list.groupChat'
  hi = (data) ->
    console.log 'got hi in menu'
    console.log data
    if $state.current.name is 'list.userlists'
      return
    $scope.msgHeaderShow = true
    $scope.headerMsg = '<p> ' + data.fromName + ' Say HI' + '<p> Click to show profile'
    $scope.msgHeaderClass = 'private_msg_push'
    $scope.headerClickAction = ->
      $scope.CloseHeaderMsg()
      $scope.user = data
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
  socket.on "message", message
  socket.on "groupMessage", groupMessage
  socket.on "hi", hi
  $scope.chatRoom = (user) ->
    if $scope.modalInstance? 
      $scope.modalInstance.close()
    history.pushState(null, null, '#/list/userlists')
    $state.go 'list.single',
      userId: user._id