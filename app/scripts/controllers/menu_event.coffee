'use strict'

angular.module('hiin').controller 'MenuEventCtrl', ($rootScope,$scope,Util,$http,socket,$log,$state,$ionicScrollDelegate, $ionicNavBarDelegate, $timeout,$ionicModal,$window) ->
  #init
  $rootScope.selectedItem = 3
  ionic.DomUtil.ready ->
    $ionicNavBarDelegate.showBackButton(false)
  #오너인지도 확인해야함..
  if window.localStorage['thisEvent']?
    $scope.enteredEventsOrOwner = true
  socket.emit "enteredEventList"
  socket.on "enteredEventList", (data) ->
    ###
    리스트 작성
    우선순위
    1. 현재 이벤트
    2. 내가 생성한 이벤트
    3. 이벤트
    ###
    $scope.thisEvent = new Array()
    $scope.thisEvent.code = $window.localStorage.getItem 'thisEvent'
    $scope.myId = new Array()
    $scope.myId.author = $window.localStorage.getItem 'myId'
    $scope.events = data
  #↑init
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeAllListeners()
    if $scope.modal?
      $scope.modal.hide()
    return  
  $scope.confirmCode = ->
    promise = Util.ConfirmEvent($scope.formData )
    $scope.message = 'loaded'
    Util.ShowModal($scope,'create_or_loaded_event')
    $timeout (->
      promise.then (data) ->
        $scope.modal.hide()
        $state.go('list.userlists')
      ,(status) ->
        console.log 'error'
        $scope.modal.hide()
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
    $state.go('list.organizerSignUp')
  $scope.no = ->
    $scope.modal.hide()
  $scope.myEvent = (event) ->
    return event.code isnt $scope.thisEvent.code && event.author == $scope.myId.author
  $scope.pastEvent = (event) ->
    return event.code isnt $scope.thisEvent.code && event.author isnt $scope.myId.author
  $scope.GotoEvent = (code) ->
    confirmData =
      code: code
    Util.ConfirmEvent(confirmData)
    .then (data) ->
      $state.go('list.userlists')
    ,(status) ->
      console.log 'error'
      Util.ShowModal($scope,'no_event')
  $scope.back = ->
    $scope.modal.hide()
