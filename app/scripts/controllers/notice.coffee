angular.module('hiin').controller 'NoticeCtrl', ($rootScope,$scope,SocketClass, Util,$window,socket,$state,$modal,$ionicNavBarDelegate,$stateParams) ->  
  console.log 'grpChat'
  #init
  #
  MakeNoticeListOptionObj = ->
    socketNotice = new SocketClass.socketClass('allNotice',null,0,true)
    socketNotice.onCallback = (data) ->
      console.log data
    return socketNotice
  SendEmitCurrentEventUserList = ->
    SocketClass.resSocket(MakeNoticeListOptionObj())
      .then (data) ->
        console.log 'socket got notice list'
      , (status) ->
        console.log "error"
    return
  $scope.roomName = "NOTICE"
  SendEmitCurrentEventUserList()
  $scope.Back = ->
    console.log 'back'
    $window.history.back()
