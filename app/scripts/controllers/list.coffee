'use strict'

angular.module('hiin').controller 'ListCtrl', ($route, $rootScope,$scope, $window, Util, socket, $modal, $state,$location,$ionicNavBarDelegate,$timeout) ->
  #init
  $rootScope.selectedItem = 2
  ionic.DomUtil.ready ->
    $ionicNavBarDelegate.showBackButton(false)
  socket.emit "currentEvent"
  socket.emit "myInfo"
  $scope.users = []
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeAllListeners()
    return
  $scope.back = ->
    $scope.modal.hide()
    $window.history.back()
  socket.on "currentEvent", (data) ->
    console.log "list currentEvent"
    if data is null 
      $scope.message = '<p> You have not entered an event. 
      <p> Please go back 
      <p> and 
      <p>type passcode to join an event.'
      Util.ShowModal($scope,'no_event')
    $scope.eventName = data.name
    $window.localStorage.setItem 'thisEvent', data.code
    $window.localStorage.setItem 'eventOwner', data.author
    socket.emit "currentEventUserList"
    console.log "socket emit current event user list"
    return
  socket.on "myInfo", (data) ->
    console.log "list myInfo"
    console.log data
    $window.localStorage.setItem 'myId', data._id
    #임시 방편.
    $ionicNavBarDelegate.showBackButton(false)
    return
  socket.on "currentEventUserList", (data) ->
    console.log "list currentEventUserList"
    $scope.users = data
    console.log data
    #임시 방편.
    $ionicNavBarDelegate.showBackButton(false)
  socket.on "userListChange", (data) ->
    console.log 'userListChange'
    console.log data
    socket.emit "currentEventUserList"
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
  socket.on "hi", (data) ->
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
  socket.on "hiMe", (data) ->
      socket.emit "currentEventUserList"
  socket.on "pendingHi", (data) ->
    console.log "list pedinghi"
    if data.status isnt "0"
      console.log('error':data.status)
      return
    socket.emit "currentEventUserList"
  $scope.activity = ->
  	$location.url('/list/activity')
  $scope.groupChat = ->
    $location.url('/list/groupChat')
  $scope.info = ->
    $location.url('/list/eventInfo')
  #for test
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
  $scope.CloseDialog = ->
    $scope.modalInstance.close()
  $scope.ShowPrivacyFreeDialog()
#accept : 3, request:1, pending:2, else :0
angular.module("hiin").directive "ngHiBtn", ($window)->
  link: (scope, element, attrs) ->
    console.log attrs.histatus
    if attrs.histatus is '0'
      console.log('btn status = hi')
      element.addClass 'btn-front'
    else if attrs.histatus is '2'
      element.addClass 'btn-Hi'
      element.addClass 'btn-front'
    else
      console.log ('btn Status = in')
      element.addClass 'btn-back'
      console.log element 
angular.module("hiin").directive "ngInBtn", ($window)->
  link: (scope, element, attrs) ->
    console.log attrs.histatus
    if attrs.histatus is '0' or attrs.histatus is '2' 
      console.log('btn status = hi')
      element.addClass 'btn-back'
    else
      console.log ('btn Status = in')
      element.addClass 'btn-front'
      console.log element
angular.module("hiin").directive "ngFlipBtn", ($window)->
  link: (scope, element, attrs) ->
    console.log attrs.histatus
    if attrs.histatus is '0' 
      element.bind 'click', ()->
        element.addClass 'btn-flip'
        console.log('addclass')
    else if attrs.histatus is '2'
      element.bind 'click', ()->
        element.addClass 'btn-flip'
        console.log('addclass')
    else
      console.log ('btn Status = in')
