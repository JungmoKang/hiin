'use strict'

angular.module('hiin').controller 'LoginCtrl', ($rootScope, $scope,$window,$state,Util,$q,$timeout) ->
	#test
	disconnect_flg = $window.localStorage.getItem "socket_disconnect"
	if disconnect_flg is '1'
		$window.localStorage.removeItem 'socket_disconnect'
		window.location.href = unescape(window.location.pathname)
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
		eventInfo = $window.localStorage.getItem "thisEvent"
		if token? and eventInfo?
			CheckToken(token)
				.then (response) ->
					console.log 'token check ok'
					eventCode = JSON.parse(eventInfo).code
					CheckEvent(eventCode)
				.then (response) ->
					confirmData =
						code: JSON.parse(eventInfo).code
					Util.ConfirmEvent(confirmData)
				.then (response) ->
					console.log 'goto events'
					$state.go('list.events')
				,(response) ->
					Util.ClearLocalStorage()
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
	LoginWithFacebook = (sendData) ->
		deferred = $q.defer()
		Util.makeReq('post','loginWithFacebook', sendData)
			.success (response) ->
				if response.status is '0'
					deferred.resolve response
				else
					deferred.reject response
				return
			.error (response, status) ->
	        	deferred.reject response
	    return deferred.promise
	$scope.facebookLogin = ->
		unless window.cordova
			#appId = prompt("Enter FB Application ID", "")
			facebookConnectPlugin.browserInit '684817121572800'
		FacebookLogin()
			.then (response) ->
				accessToken = response.authResponse.accessToken
				console.log accessToken
				sendData = {}
				sendData.accessToken = accessToken
				sendData.device = $rootScope.deviceType
				sendData.deviceToken = $rootScope.deviceToken
				console.log sendData
				LoginWithFacebook(sendData)
			.then (response) ->
				Util.ClearLocalStorage()
				$window.localStorage.setItem "auth_token", response.Token
				$window.localStorage.setItem "id_type", 'facebook'
				$state.go('list.events')
			,(response) ->
				alert 'error'
	$scope.signin = ->
		$state.go('signin')
	$scope.organizerLogin = ->
		$state.go('organizerLogin')