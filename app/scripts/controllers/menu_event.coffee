'use strict'

angular.module('hiin').controller 'MenuEventCtrl', ($scope,Util,$http,socket,$log,$state) ->
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeAllListeners()
    return  
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
    $scope.thisEvent.code = window.localStorage['thisEvent']
    $scope.myId = new Array()
    $scope.myId.author = window.localStorage['myId']
    $scope.events = data
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
      alert "invalid event code"
  $scope.goToCreateEvent = ->
    console.log('goto Create Event');
    $state.go('createEventAttention')