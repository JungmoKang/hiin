'use strict'

angular.module('hiin').controller 'MenuEventCtrl', ($rootScope,$scope,Util,$http,socket,SocketClass,$log,$state,$ionicScrollDelegate, $ionicNavBarDelegate, $timeout,$ionicModal,$window) ->
  #init
  $rootScope.selectedItem = 3
  ionic.DomUtil.ready ->
    $ionicNavBarDelegate.showBackButton(false)
  $scope.thisEvent = new Array()
  event = $window.localStorage.getItem 'thisEvent'
  if event?
    $scope.enteredEventsOrOwner = true
    $scope.thisEvent.code = JSON.parse(event).code
  else
    Util.checkOrganizer()
      .then (data) ->
        console.log '---organizer state----'
        if data.status == "0"
          $scope.enteredEventsOrOwner = true
      , (status) ->
        console.log '-----user or error-----'
        console.log status
        console.log "error"
    $scope.thisEvent.code = ""    
  myinfo = $window.localStorage.getItem "myInfo"
  #socket 관련
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
  MakeEventListObj = () ->
    socketMyInfo = new SocketClass.socketClass('enteredEventList',null,0,true)
    socketMyInfo.onCallback = (data) ->
      $scope.events = data
      return
    return socketMyInfo  
  SendEmitMyInfo = () ->
    SocketClass.resSocket(MakeMyInfoOptionObj())
      .then (data) ->
        console.log 'socket got myInfo'
        SocketClass.resSocket(MakeEventListObj())
      .then (data) ->
        console.log 'socket got event list'
      , (status) ->
        console.log "error"
  if !myinfo?
    SendEmitMyInfo()
  else
    $scope.myId = new Array()
    $scope.myId.author = JSON.parse($window.localStorage.getItem 'myInfo')._id
    SocketClass.resSocket(MakeEventListObj())
      .then (data) ->
        console.log 'socket got event list'
      , (status) ->
        console.log "error"              
  # ↑
  $scope.$on "$destroy", (event) ->
    if $scope.modal?
      $scope.modal.hide()
      $scope.modal.remove()
    return
  SetNewEvent = (data) ->
    if $scope.thisEvent.code != ""
      console.log $scope.thisEvent.code
      deleteKeyList = []
      for i in [0..$window.localStorage.length-1]
        console.log i
        if $window.localStorage.key(i).indexOf($scope.thisEvent.code) >= 0
          deleteKeyList.push($window.localStorage.key(i))
      for key in deleteKeyList
        $window.localStorage.removeItem key
    $window.localStorage.setItem 'thisEvent', JSON.stringify(data.event)
    $state.go('list.userlists')
  $scope.confirmCode = ->
    promise = Util.ConfirmEvent($scope.formData )
    $scope.message = 'loaded'
    Util.ShowModal($scope,'create_or_loaded_event')
    $timeout (->
      promise.then (data) ->
        $scope.modal.hide()
        $scope.modal.remove()
        SetNewEvent(data)
      ,(status) ->
        console.log 'error'
        $scope.modal.hide()
        $scope.modal.remove()
        $scope.message = 'EVENT NOT FOUND'
        Util.ShowModal($scope,'no_event')
    ), 1000
  $scope.CreateEvent = ->
    #TODO: 이미 오거나이저등록을 했는지 확인이 필요함
    #이미 등록을 했으면 바로 생성 페이지로 이동 안했으면 다이얼로그 표시
    Util.checkOrganizer()
      .then (data) ->
        console.log '---organizer state----'
        if data.status == "0"
          # 오거나이저
          $window.localStorage.setItem 'flg_show_privacy_dialog', true
          $state.go('list.createEvent')
        else if data.status == "1"
          # 가입시켜야함
          Util.ShowModal($scope, 'create_event_attention')
        else
          alert "error:status->" + data.status
      , (status) ->
        console.log '-----user or error-----'
        console.log status
        alert "error"
  $scope.yes = ->
    $scope.modal.hide()
    $scope.modal.remove()
    id_type = $window.localStorage.getItem "id_type"
    if id_type is "facebook"
      Util.authReq('get','organizerFbSignUp','')
        .success (data) ->
          console.log data
          if data.status is '0'
            $scope.CreateEvent()
        .error (data, status) ->
          console.log data
    else
      $state.go('list.organizerSignUp')
  $scope.no = ->
    $scope.modal.hide()
    $scope.modal.remove()
  $scope.current = (event) ->
    return event.code is $scope.thisEvent.code
  $scope.myEvent = (event) ->
    return event.code isnt $scope.thisEvent.code && event.author == $scope.myId.author
  $scope.pastEvent = (event) ->
    return event.code isnt $scope.thisEvent.code && event.author isnt $scope.myId.author
  $scope.GotoEvent = (code) ->
    confirmData =
      code: code
    Util.ConfirmEvent(confirmData)
      .then (data) ->
        SetNewEvent(data)
      ,(status) ->
        console.log 'error'
        Util.ShowModal($scope,'no_event')
  $scope.back = ->
    $scope.modal.hide()
    $scope.modal.remove()
