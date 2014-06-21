'use strict'

angular.module('hiin').controller 'LoginCtrl', ($scope,$window,$state) ->
	if $window.localStorage?
		$window.localStorage.clear()
	if navigator.userAgent.match(/(iPhone|iPod|iPad|Android|BlackBerry|IEMobile)/)
	  $window.localStorage.setItem "isPhoneGap", "1"
	$scope.facebookLogin = ->
		alert('facebooklogin')
	$scope.signin = ->
		$state.go('signin')
	$scope.organizerLogin = ->
	  $state.go('organizerLogin')