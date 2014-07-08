'use strict'

angular.module('hiin').controller 'LoginCtrl', ($scope,$window,$state,Util,$q,$timeout) ->
	if window.cordova
		$window.localStorage.setItem "isPhoneGap", "1"
	CheckToken = (token) ->
		deferred = $q.defer()
		sendData = {}
		sendData.Token = token
		Util.makeReq('post','IsAvailableToken', sendData)
			.success (data) ->
				console.log data
				if data.status is '0'
					deferred.resolve 'ok'
				else
					deferred.reject 'error'
				return
			.error (data, status) ->
				deferred.reject 'error'
		return deferred.promise
	CheckEvent = (eventCode) ->
		deferred = $q.defer()
		sendData = {}
		sendData.code = eventCode
		Util.makeReq('post','IsAvailableEvent', sendData)
			.success (data) ->
				console.log data
				if data.status is '0'
					deferred.resolve 'ok'
				else
					deferred.reject 'error'
				return
			.error (data, status) ->
				deferred.reject 'error'
		return deferred.promise
	if $window.localStorage?
		token = $window.localStorage.getItem "auth_token"
		eventCode = $window.localStorage.getItem "thisEvent"
		if token? and eventCode?
			CheckToken(token)
				.then (response) ->
					CheckEvent(eventCode)
				.then (response) ->
					$state.go('list.events')
				,(response) ->
					Util.ClearLocalStorage()
					alert 'error'
	FacebookLogin = ->
		deferred = $q.defer()
		facebookConnectPlugin.login ["email"], ((response) ->
			if response.status is 'connected'
				deferred.resolve response
			else
				deferred.reject response
			return
		), (response) ->
			console.log JSON.stringify(response)
			deferred.reject response
			return
		return deferred.promise
	test = ->
		deferred = $q.defer()
		$timeout (->
		  deferred.resolve 'ok'
		), 3000
		return deferred.promise
	$scope.facebookLogin = ->
		unless window.cordova
			appId = prompt("Enter FB Application ID", "")
			facebookConnectPlugin.browserInit appId
		FacebookLogin()
			.then (response) ->
				accessToken = response.authResponse.accessToken
				console.log accessToken
				sendData = {}
				sendData.accessToken = accessToken
				test()
				###
				Util.makeReq('post','loginWithFacebook', sendData)
					.success (data) ->
						alert 'success'
			        .error (data, status) ->
			        	alert 'error'
			    ###	
			.then (response) ->
				$state.go('list.events')
			,(response) ->
				alert 'error'
	$scope.signin = ->
		$state.go('signin')
	$scope.organizerLogin = ->
		$state.go('organizerLogin')