'use strict'

angular.module('hiin').controller 'CreateEventCtrl', ($scope,$window,$modal,Util,Host,$q,$state) ->
	#create event promise
	$scope.dateOptions = 
        minDate: new Date()
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
			if typeof $scope.eventInfo.startDate is 'undefined' || !$scope.eventInfo.startDate? 
				alert 'input start date'
				return 
			$scope.eventInfo.startDate.setHours($scope.time.split(":")[0])
			$scope.eventInfo.startDate.setMinutes($scope.time.split(":")[1])
			$scope.eventInfo.endDate = new Date($scope.eventInfo.startDate.getTime())
			$scope.eventInfo.endDate.setMinutes($scope.eventInfo.endDate.getMinutes() + $scope.durationHour * 60)
			$scope.CreateEvent($scope.eventInfo)
        .then (data) ->
          console.log data
          confirmData =
            code: data.eventCode
          $scope.eventCode = data.eventCode
          Util.ConfirmEvent(confirmData)
          .then (data) ->
            modalInstance = $modal.open(
              templateUrl: "views/event/passcode_dialog.html"
              scope: $scope
              )
            modalInstance.result.then  ->
              console.log '불가'
            , ->
              $state.go('list.userlists')
          ,(status) ->
            alert "invalid event code"
        ,(status) ->
          alert 'err'
    return
	$scope.yes = ->
		$state.go('createEvent')
	$scope.no = ->
		$window.history.back()
	$scope.backToList =->
    $window.history.back()
