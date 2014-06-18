'use strict'

angular.module('hiin').controller 'eventInfoCtrl', ($scope,$rootScope,socket,$window,Util,$modal) ->
  $scope.slide = ''
  socket.emit "currentEvent"
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeAllListeners()
    return  
  socket.on "currentEvent", (data) ->
    $scope.eventInfo = data
    if $window.localStorage.getItem 'myId' is data.author
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
