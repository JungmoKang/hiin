'use strict'

angular.module('hiin')
  .controller 'LoginCtrl', ($scope,$window,$state) ->
    if $window.localStorage?
    	$window.localStorage.clear()
    $scope.facebookLogin = ->
    	alert('facebooklogin')
    $scope.signin = ->
    	$state.go('signin')
    $scope.organizerLogin = ->
      $state.go('organizerLogin')