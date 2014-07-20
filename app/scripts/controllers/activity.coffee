'use strict'

angular.module('hiin').controller 'ActivityCtrl', ($scope, $state,$rootScope,$location, $window, Util, socket, SocketClass, $modal) ->
    rankKey = 'activity_rank'
    activityKey = 'activity_activity'
    if $window.localStorage.getItem rankKey
      $scope.rank = $window.localStorage.getItem rankKey
    if $window.localStorage.getItem activityKey
      $scope.activitys = $window.localStorage.getItem activityKey
    MakeActivityOptionObj = ->
      socketMyInfo = new SocketClass.socketClass('activity',null,500,true)
      socketMyInfo.onCallback = (data) ->
        $scope.rank = data.rank
        $scope.activitys = data.activity
        console.log "activity"
        console.log data
        return
      return socketMyInfo
    SocketClass.resSocket(MakeActivityOptionObj())
      .then (data) ->
        console.log 'socket got activity'
      , (status) ->
        console.log "error"
    #scope가 destroy될때, 등록한 이벤트를 모두 지움
    $scope.$on "$destroy", (event) ->
      $window.localStorage.setItem rankKey, $scope.rank 
      $window.localStorage.setItem activityKey, $scope.activitys
      return
    $scope.myInfo = JSON.parse($window.localStorage.getItem 'myInfo')
    $scope.showRank =->
      $scope.modalInstance = $modal.open(
        templateUrl: "views/list/rank_modal.html"
        scope: $scope
      )
    $scope.ok = -> 
        $scope.modalInstance.close()
    $scope.ShowProfile = (user) ->
      console.log user
      $scope.user = user
      if user.status is '0' or user.status is '2'
        modalInstance = $modal.open(
          templateUrl: "views/dialog/user_card.html"
          scope: $scope
        )
        modalInstance.result.then ((selectedItem) ->
          return
        ), ->
          $scope.modalInstance = null
          return
        $scope.modalInstance = modalInstance
      else
        $scope.chatRoom(user)
    $scope.chatRoom = (user) ->
      console.log(user)
      if $scope.modalInstance? 
        $scope.modalInstance.close()
      $state.go 'list.single',
        userId: user._id
    $scope.sayHi = (user) ->
      if user.status == '0'
        console.log 'sayhi'
        setTimeout () -> 
          socket.emit "hi" , {
            targetId : user._id
          }, 100000
        return
angular.module('hiin').filter 'convertMsg', () ->
  return (activity) -> 
    if activity.lastMsg.type == 'hi' 
      return 'Sent \'HI\'!'
    else
      return activity.lastMsg.content
 
angular.module('hiin').filter 'fromNow', () ->
  return (time) -> 
    moment(time).fromNow()
