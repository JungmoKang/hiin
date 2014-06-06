'use strict'

angular.module('hiin')
  .controller 'LoginCtrl', ($scope,$window,$location) ->
    if $window.localStorage?
    	$window.localStorage.clear()
    $scope.facebookLogin = ->
    	alert('facebooklogin')
    $scope.signUp = ->
    	$location.url('/signUp')
    $scope.emailLogin = ->
      $location.url('/emailLogin')