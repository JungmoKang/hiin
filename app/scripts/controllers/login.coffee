'use strict'

angular.module('hiin').controller 'LoginCtrl', ($scope,$window,$state,Util) ->
	if $window.localStorage?
		$window.localStorage.clear()
	if window.cordova
		$window.localStorage.setItem "isPhoneGap", "1"
	$scope.facebookLogin = ->
		unless window.cordova
			appId = prompt("Enter FB Application ID", "")
			facebookConnectPlugin.browserInit appId
		facebookConnectPlugin.login ["email"], ((response) ->
			if response.status is 'connected'
				accessToken = response.authResponse.accessToken
				console.log accessToken
				sendData = {}
				sendData.accessToken = accessToken
				Util.makeReq('post','loginWithFacebook', sendData)
					.success (data) ->
						alert 'success'
			        .error (data, status) ->
			        	alert 'error'
			else
				alert 'login error'
			console.log JSON.stringify(response)
			return
		), (response) ->
			console.log JSON.stringify(response)
			return
		return
	$scope.signin = ->
		$state.go('signin')
	$scope.organizerLogin = ->
		$state.go('organizerLogin')