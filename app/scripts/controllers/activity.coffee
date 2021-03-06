'use strict'

angular.module('hiin').controller 'ActivityCtrl', ($scope, $filter,$state,$rootScope,$location, $window, Util, socket, SocketClass, $modal) ->
    thisEvent = JSON.parse($window.localStorage.getItem "thisEvent").code
    MakeActivityOptionObj = (msgFlag) ->
      socketMyInfo = new SocketClass.socketClass('activity',null,500,msgFlag)
      socketMyInfo.onCallback = (data) ->
        $scope.rank = data.rank
        #$scope.activitys = data.activity
        $scope.activitys = $filter('orderBy')(data.activity,'lastMsg.created_at','reverse')
        console.log "activity"
        console.log data
        return
      return socketMyInfo
    SendEmitActivity = (msgFlag) ->
      SocketClass.resSocket(MakeActivityOptionObj(msgFlag))
        .then (data) ->
          console.log 'socket got activity'
        , (status) ->
          console.log "error"
    SendEmitActivity(true)
    #scope가 destroy될때, 등록한 이벤트를 모두 지움
    $scope.$on "$destroy", (event) ->
      return
    $scope.myInfo = JSON.parse($window.localStorage.getItem 'myInfo')
    $scope.showRank = ->
      modalInstance = $modal.open(
        templateUrl: "views/dialog/ranking.html"
        scope: $scope
      )
      modalInstance.result.then ((selectedItem) ->
          $scope.modalInstance = null
          return
        ), ->
          $scope.modalInstance = null
          return
      $scope.modalInstance = modalInstance
    $scope.ok = -> 
        $scope.modalInstance.close()
        $scope.modalInstance = null
    $scope.ShowProfile = (user) ->
      console.log user
      $scope.user = user
      if user.status is '0' or user.status is '2'
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
      else
        $scope.chatRoom(user)
    $scope.chatRoom = (user) ->
      console.log(user)
      if $scope.modalInstance? 
        $scope.modalInstance.close()
      $state.go 'list.single',
        userId: user._id
    $scope.sayHi = (user) ->
      if user.status is '0' or user.status is '2'
        console.log 'sayhi'
        socket.emit "hi" , {
          targetId : user._id
        }
        if user.status is '2'
          socket.emit "readHi" , {
            partner : user._id
            code : thisEvent
          }
      return
    $scope.$on "update activity", (event,args) ->
      console.log 'update activity'
      SendEmitActivity(false)
angular.module('hiin').filter 'convertMsg', (Util) ->
  return (activity) -> 
    if activity.lastMsg.type == 'hi' 
      return 'Sent \'HI\'!'
    else
      return  Util.trimStr(activity.lastMsg.content, 40)
 
angular.module('hiin').filter 'fromNow', () ->
  return (time) -> 
    moment(time).fromNow().replace('minute','min')
