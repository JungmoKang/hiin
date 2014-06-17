'use strict'

angular.module('hiin')
  .controller 'LoginCtrl', ($scope,$window,$location) ->
    if $window.localStorage?
    	$window.localStorage.clear()
    $scope.facebookLogin = ->
    	alert('facebooklogin')
    $scope.signin = ->
    	$location.url('/signin')
    $scope.organizerLogin = ->
      $location.url('/organizerLogin')