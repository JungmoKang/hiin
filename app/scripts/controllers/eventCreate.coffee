'use strict'

angular.module('hiin').controller 'CreateEventCtrl', ($scope,$window,$modal,Util,Host,$q,$state,$filter,$timeout) ->
  #init
  $scope.InputStartDate = ->
    console.log 'input start date'
    if $window.localStorage.getItem "isPhoneGap"
      options =
        date: new Date()
        mode: "datetime"
      window.plugins.datePicker.show options, (date) ->
        $scope.eventInfo.startDate = new Date(date)
        $scope.eventInfo.endDate = new Date(date)
        $scope.eventInfo.endDate.setTime($scope.eventInfo.endDate.getTime() + (2*60*60*1000))
        $scope.startDate = $filter('date')($scope.eventInfo.startDate, 'MMM d, y h:mm a')
        $scope.endDate = $filter('date')($scope.eventInfo.endDate, 'MMM d, y h:mm a')
        $scope.$apply()
        return
    else
      $scope.eventInfo.startDate = new Date()
      $scope.eventInfo.endDate = new Date()
      $scope.eventInfo.endDate.setTime($scope.eventInfo.endDate.getTime() + (2*60*60*1000))
      $scope.startDate = $filter('date')($scope.eventInfo.startDate, 'MMM d, y h:mm a')
      $scope.endDate = $filter('date')($scope.eventInfo.endDate, 'MMM d, y h:mm a')    
  $scope.InputEndDate = ->
    console.log 'input end date'
    if typeof $scope.eventInfo.startDate == 'undefined' || !$scope.eventInfo.startDate? 
      return 
    if $window.localStorage.getItem "isPhoneGap"
      options =
        date: new Date()
        mode: "datetime"
      window.plugins.datePicker.show options, (date) ->
        $scope.eventInfo.endDate = new Date(date)
        $scope.endDate = $filter('date')($scope.eventInfo.endDate, 'MMM d, y h:mm a')
        $scope.$apply()
        return 
    else
      $scope.eventInfo.endDate = new Date()
      $scope.endDate = $filter('date')($scope.eventInfo.endDate, 'MMM d, y h:mm a')    
  $scope.eventInfo = {}
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