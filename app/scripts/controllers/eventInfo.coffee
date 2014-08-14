'use strict'

angular.module('hiin').controller 'eventInfoCtrl', ($scope,$rootScope,socket,$window,Util,$modal,$filter,$ionicNavBarDelegate) ->
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeListener("currentEvent",currentEvent)
    return
  $scope.eventInfo = JSON.parse($window.localStorage.getItem "thisEvent")
  $scope.startDate = $filter('date')(new Date($scope.eventInfo.startDate), 'MMM d, h:mm a')
  $scope.endDate  = $filter('date')(new Date($scope.eventInfo.endDate), 'MMM d, h:mm a')
  if ($window.localStorage.getItem 'thisEventOwner') is 'true'
  	$scope.isOwner = true
  	$scope.right_link = 'edit_link'
  $rootScope.Cancel = ->
    $scope.editMode = false
    socket.emit "currentEvent"
    $scope.right_link = 'edit_link'
    $ionicNavBarDelegate.showBackButton(true)
    return
  $scope.editMode = false
  $scope.ToEditMode = ->
    if $scope.editMode is true
      Util.authReq('post','editEvent',$scope.eventInfo )
        .success (data) ->
          if data.status >= '0'
            console.log "$http.success"
            socket.emit "currentEvent"
          else
          console.log data
        .error (error, status) ->
          console.log "$http.error"
          alert 'status'
      $scope.right_link = 'edit_link'
      $ionicNavBarDelegate.showBackButton(true)
    else
      $scope.editMode = true
      $scope.right_link = 'save_link'
      $ionicNavBarDelegate.showBackButton(false)
  # socket event ↓
  currentEvent = (data) ->
    console.log "currentEvent"
    console.log data
    $window.localStorage.setItem 'thisEvent', JSON.stringify(data)
    return
  socket.on "currentEvent", currentEvent
  # ↑
  $scope.InputStartDate = ->
    if $scope.editMode is false
      return
    console.log 'input start date'
    if $window.localStorage.getItem "isPhoneGap"
      options =
        date: new Date($scope.eventInfo.startDate)
        mode: "datetime"
      datePicker.show options, (date) ->
        $scope.eventInfo.startDate = date
        $scope.startDate = $filter('date')($scope.eventInfo.startDate, 'MMM d, h:mm a')
        $scope.$apply()
        return
    else
      $scope.eventInfo.startDate = new Date($scope.eventInfo.startDate)
      $scope.startDate = $filter('date')($scope.eventInfo.startDate, 'MMM d, h:mm a')
  $scope.InputEndDate = ->
    if $scope.editMode is false
      return
    console.log 'input end date'
    if $window.localStorage.getItem "isPhoneGap"
      options =
        date: new Date($scope.eventInfo.endDate)
        mode: "datetime"
      datePicker.show options, (date) ->
        $scope.eventInfo.endDate = date
        $scope.endDate = $filter('date')($scope.eventInfo.endDate, 'MMM d, h:mm a')
        $scope.$apply()
        return 
    else
      $scope.eventInfo.endDate = new Date($scope.eventInfo.endDate)
      $scope.endDate = $filter('date')($scope.eventInfo.endDate, 'MMM d, h:mm a') 
