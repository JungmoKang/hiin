'use strict'

angular.module('hiin').controller 'CreateEventCtrlPc', ($scope,$window,$modal,Util,Host,$q,$state,$filter,$timeout) ->
  #init
  $scope.eventInfo = {}
  today = new Date()
  $scope.startDate = new Date()
  $scope.startTime = new Date()
  $scope.endDate = new Date()
  $scope.endTime = new Date()
  $scope.CreateEvent = (eventInfo) ->
  	deferred = $q.defer()
  	Util.authReq('post','event',eventInfo)
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
      promise = $scope.CreateEvent($scope.eventInfo)
      $scope.message = 'created'
      Util.ShowModal($scope,'create_or_loaded_event')
      $timeout (->
        promise.then (data) ->
          console.log data
          thisEvent = $scope.eventInfo
          thisEvent.code = data.eventCode
          thisEvent.author = JSON.parse($window.localStorage.getItem 'myInfo')._id
          $window.localStorage.setItem 'thisEventOwner', 'true'
          $window.localStorage.setItem 'thisEvent', JSON.stringify(thisEvent)
          $scope.modal.hide()
          $scope.modal.remove()
          $scope.eventCode = data.eventCode
          modalInstance = $modal.open(
            templateUrl: "views/event/passcode_dialog.html"
            scope: $scope
            )
          modalInstance.result.then  ->
            console.log 'test'
          , ->
            $state.go('list.userlists')
        ,(status) ->
          console.log 'error'
          $scope.modal.hide()
          $scope.modal.remove()
          alert 'err'
      ), 1000
    return