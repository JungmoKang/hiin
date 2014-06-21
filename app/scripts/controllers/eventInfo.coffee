'use strict'

angular.module('hiin').controller 'eventInfoCtrl', ($scope,$rootScope,socket,$window,Util,$modal,$filter) ->
  socket.emit "currentEvent"
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeAllListeners()
    return  
  socket.on "currentEvent", (data) ->
    $scope.eventInfo = data
    $scope.startDate = $filter('date')(new Date($scope.eventInfo.startDate), 'MMM d, y h:mm a')
    $scope.endDate  = $filter('date')(new Date($scope.eventInfo.endDate), 'MMM d, y h:mm a')
    if ($window.localStorage.getItem 'myId') is data.author
    	$scope.isOwner = true
    	$scope.right_link = 'edit_link'
    return
  $rootScope.back = ->
  	if $scope.editMode is true
  		$scope.editMode = false
  		socket.emit "currentEvent"
  		$scope.right_link = ''
  	else
	    $scope.slide = 'slide-right'
	    $window.history.back()
  $scope.ToEditMode = ->
  	if $scope.editMode is true
  		Util.makeReq('post','editEvent',$scope.eventInfo )
				.success (data) ->
					if data.status >= '0'
						console.log "$http.success"
						socket.emit "currentEvent"
					else
						console.log data
				.error (error, status) ->
	        console.log "$http.error"
	        alert 'status'
  	else
	  	$scope.editMode = true
	  	$scope.right_link = 'save_link'
  $scope.InputStartDate = ->
    console.log 'input start date'
    if $window.localStorage.getItem "isPhoneGap"
      options =
        date: new Date($scope.eventInfo.startDate)
        mode: "datetime"
      datePicker.show options, (date) ->
        $scope.eventInfo.startDate = date
        $scope.startDate = $filter('date')($scope.eventInfo.startDate, 'MMM d, y h:mm a')
        $scope.$apply()
        return
    else
      $scope.eventInfo.startDate = new Date($scope.eventInfo.startDate)
      $scope.startDate = $filter('date')($scope.eventInfo.startDate, 'MMM d, y h:mm a')
  $scope.InputEndDate = ->
    console.log 'input end date'
    if $window.localStorage.getItem "isPhoneGap"
      options =
        date: new Date($scope.eventInfo.endDate)
        mode: "datetime"
      datePicker.show options, (date) ->
        $scope.eventInfo.endDate = date
        $scope.endDate = $filter('date')($scope.eventInfo.endDate, 'MMM d, y h:mm a')
        $scope.$apply()
        return 
    else
      $scope.eventInfo.endDate = new Date($scope.eventInfo.endDate)
      $scope.endDate = $filter('date')($scope.eventInfo.endDate, 'MMM d, y h:mm a') 
