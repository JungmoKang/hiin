'use strict'

angular.module('hiin').controller 'CreateEventCtrlAndroid', ($scope,$window,$modal,Util,Host,$q,$state,$filter,$timeout) ->
  #init
  $scope.no_padding = '{padding-left:"0px"}'
  $scope.eventInfo = {}
  $scope.eventInfo.name = ""
  $scope.eventInfo.startDate = ""
  $scope.eventInfo.endDate = ""
  $scope.eventInfo.place = ""
  $scope.eventInfo.desc = ""
  ###
  Start혹은 end가 입력되었을때 초기값이 없다면, 입력된 값을 초기값으로 date생성,
  Time이 먼저 입력되었을때는, 오늘 날짜로 생성 
  ###
  SetDateTime = ->
    $scope.startDate = $filter('date')($scope.eventInfo.startDate, 'MMM d, y')
    $scope.startTime = $filter('date')($scope.eventInfo.startDate, 'h:mm a')
    $scope.endDate = $filter('date')($scope.eventInfo.endDate, 'MMM d, y')
    $scope.endTime = $filter('date')($scope.eventInfo.endDate, 'h:mm a')
    $scope.$apply()
  isValidDate = (d) ->
    return false  if Object::toString.call(d) isnt "[object Date]"
    not isNaN(d.getTime())
  $scope.InputStartDate = ->
    console.log 'input start date'
    tmpDate = ""
    if !$scope.eventInfo.startDate
      tmpDate = new Date()
    else
      tmpDate = new Date($scope.eventInfo.startDate)
    options =
      date: tmpDate
      mode: "date"
    window.plugins.datePicker.show options, (date) ->
      console.log date
      if !isValidDate(date)
        return
      tmpDate = ""
      if !$scope.eventInfo.startDate
        tmpDate = new Date()
        tmpDate.setHours(18)
        tmpDate.setMinutes(0)
      else
        tmpDate = new Date($scope.eventInfo.startDate)
      $scope.eventInfo.startDate = new Date(date)
      $scope.eventInfo.startDate.setHours(tmpDate.getHours())
      $scope.eventInfo.startDate.setMinutes(tmpDate.getMinutes())
      if !$scope.eventInfo.endDate
        $scope.eventInfo.endDate = new Date($scope.eventInfo.startDate)
        $scope.eventInfo.endDate.setTime($scope.eventInfo.endDate.getTime() + (2*60*60*1000))
      SetDateTime()
  $scope.InputStartTime = ->
    console.log 'input start time'
    tmpDate = ""
    if !$scope.eventInfo.startDate
      tmpDate = new Date()
      tmpDate.setHours(18)
    else
      tmpDate = new Date($scope.eventInfo.startDate)
    options =
      date: tmpDate
      mode: "time"
    window.plugins.datePicker.show options, (date) ->
      if !isValidDate(date)
        return
      if !$scope.eventInfo.startDate
        $scope.eventInfo.startDate = new Date()
      $scope.eventInfo.startDate.setHours(date.getHours())
      $scope.eventInfo.startDate.setMinutes(date.getMinutes())
      if !$scope.eventInfo.endDate
        $scope.eventInfo.endDate = new Date($scope.eventInfo.startDate)
        $scope.eventInfo.endDate.setTime($scope.eventInfo.endDate.getTime() + (2*60*60*1000))
      SetDateTime()
    return 
  $scope.InputEndDate = ->
    console.log 'input end date'
    tmpDate = ""
    if !$scope.eventInfo.endDate
      tmpDate = new Date()
      tmpDate.setHours(20)
    else
      tmpDate = new Date($scope.eventInfo.endDate)
    options =
      date: tmpDate
      mode: "date"
    window.plugins.datePicker.show options, (date) ->
      console.log date
      if !isValidDate(date)
        return
      tmpDate = ""
      if !$scope.eventInfo.endDate
        tmpDate = new Date()
        tmpDate.setHours(20)
        tmpDate.setMinutes(0)
      else
        tmpDate = new Date($scope.eventInfo.endDate)
      $scope.eventInfo.endDate = new Date(date)
      $scope.eventInfo.endDate.setHours(tmpDate.getHours())
      $scope.eventInfo.endDate.setMinutes(tmpDate.getMinutes())
      if !$scope.eventInfo.startDate
        $scope.eventInfo.startDate = new Date($scope.eventInfo.endDate)
        $scope.eventInfo.startDate.setTime($scope.eventInfo.startDate.getTime() - (2*60*60*1000))
      SetDateTime()
  $scope.InputEndTime = ->
    console.log 'input end time'
    tmpDate = ""
    if !$scope.eventInfo.endDate
      tmpDate = new Date()
      tmpDate.setHours(20)
    else
      tmpDate = new Date($scope.eventInfo.endDate)
    options =
      date: tmpDate
      mode: "time"
    window.plugins.datePicker.show options, (date) ->
      if !isValidDate(date)
        return
      if !$scope.eventInfo.endDate
        $scope.eventInfo.endDate = new Date()
      $scope.eventInfo.endDate.setHours(date.getHours())
      $scope.eventInfo.endDate.setMinutes(date.getMinutes())
      if !$scope.eventInfo.startDate
        $scope.eventInfo.startDate = new Date($scope.eventInfo.endDate)
        $scope.eventInfo.startDate.setTime($scope.eventInfo.startDate.getTime() - (2*60*60*1000))
      SetDateTime()
    return 
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