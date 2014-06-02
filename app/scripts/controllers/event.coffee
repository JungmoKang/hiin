'use strict'

angular.module('hiin').controller 'eventCtrl', ($scope,$http,$window,Util,$location,$state) ->
    $scope.slide = ''
    $scope.back = ->
      $scope.slide = 'slide-right'
      $window.history.back()
    $scope.confirmCode = ->
      Util.ConfirmEvent($scope.formData )
      .then (data) ->
        $state.go('list.userlists',null,{ 'reload': true})
      ,(status) ->
        alert "invalid event code"
    $scope.goToCreateEvent = ->
      console.log('goto Create Event');
      $state.go('createEventAttention')