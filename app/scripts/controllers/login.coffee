'use strict'

angular.module('hiin').controller 'LoginCtrl', ($scope,$window,$state) ->
	if $window.localStorage?
		$window.localStorage.clear()
	if navigator.userAgent.match(/(iPhone|iPod|iPad|Android|BlackBerry|IEMobile)/)
		$window.localStorage.setItem "isPhoneGap", "1"
	$scope.facebookLogin = ->
		unless window.cordova
			appId = prompt("Enter FB Application ID", "")
			facebookConnectPlugin.browserInit appId
		facebookConnectPlugin.login ["email"], ((response) ->
			alert JSON.stringify(response)
			return
		), (response) ->
			alert JSON.stringify(response)
			return
		return
	$scope.signin = ->
		$state.go('signin')
	$scope.organizerLogin = ->
		$state.go('organizerLogin')