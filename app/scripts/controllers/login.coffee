'use strict'

angular.module('hiin')
  .controller 'LoginCtrl', ($scope,$window,$location) ->
    $scope.facebookLogin = ->
    	alert('facebooklogin')
    $scope.signUp = ->
    	$location.url('/signUp')
    $scope.emailLogin = ->
      $location.url('/emailLogin')