'use strict'

angular.module('hiin').controller 'CreateEventCtrl', ($scope,$window,$modal,Util,Host,$q,$state) ->
	#init
	$scope.sDate = 
    minDate: new Date()
    onSelect: (dateText, inst) ->
    	$scope.eDate.minDate = new Date(dateText)
    	$scope.eventInfo.endDate = $scope.eventInfo.startDate
    	console.log dateText
  $scope.eDate = 
  	minDate: new Date()
  $scope.eventInfo = {}
  $scope.startTime = "00:00"
  $scope.endTime = "00:00"

	$scope.CreateEvent = (eventInfo) ->
		deferred = $q.defer()
		Util.makeReq('post','event',eventInfo)
			.success (data) ->
				if data.status >= '0'
					console.log "$http.success"
					deferred.resolve data
				else
					deferred.reject data
			.error (error, status) ->
        console.log "$http.error"
        deferred.reject status
    return deferred.promise
	#confirm event
	$scope.pubish = ->
		if $scope.eventInfo isnt null
			if typeof $scope.eventInfo.startDate == 'undefined' || !$scope.eventInfo.startDate? 
				alert 'input start date'
				return 
			$scope.eventInfo.startDate.setHours($scope.startTime.split(":")[0])
			$scope.eventInfo.startDate.setMinutes($scope.startTime.split(":")[1])
			$scope.eventInfo.endDate.setHours($scope.endTime.split(":")[0])
			$scope.eventInfo.endDate.setMinutes($scope.endTime.split(":")[1])
			$scope.CreateEvent($scope.eventInfo)
        .then (data) ->
          console.log data
          $scope.eventCode = data.eventCode
          modalInstance = $modal.open(
            templateUrl: "views/event/passcode_dialog.html"
            scope: $scope
            )
          modalInstance.result.then  ->
            console.log '불가'
          , ->
            $state.go('list.userlists')
        ,(status) ->
          alert 'err'
    return