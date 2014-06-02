'use strict'

angular.module('services').factory 'Util', ($q, $http, $window,$location,$document, Host, Token) ->
  serverUrl: ->
    "#{Host.getAPIHost()}:#{Host.getAPIPort()}"
  # 공통적으로 쓰이는 http request 만들어주는 함수
  makeReq: (method, path, param) ->
    # 요청 method가 get일때는 parameter를 url에 붙여 보내야하고 아닌 경우에는 body에 심어서 보냄
    # see : http://docs.angularjs.org/api/ng.$http
    console.log "#{Host.getAPIHost()}:#{Host.getAPIPort()}/#{path}"
    $http[method]("#{Host.getAPIHost()}:#{Host.getAPIPort()}/#{path}", (if method == "get" then params:param else param), headers: {'Content-Type': 'application/x-www-form-urlencoded'})
  authReq: (method, path, param, options) ->
    options = {} unless options?
    options.headers = {} unless options.headers?
    options.headers["Authorization"] = "#{Token.authToken()}"
    options.headers["Content-Type"] = 'application/x-www-form-urlencoded'

    opts = {}
    if method == "get" 
      opts = method:"get", url:"#{Host.getAPIHost()}:#{Host.getAPIPort()}/#{path}", params: param
    else
      opts = method:method, url:"#{Host.getAPIHost()}:#{Host.getAPIPort()}/#{path}", data: param

    opts = angular.extend opts, options

    $http opts
  emailLogin: (userInfo) ->
  	deferred = $q.defer()
  	this.makeReq('post','login', userInfo )
      .success (data) ->
        if data.status != "0"
          deferred.reject data.status
          console.log data
      #TODO:나중에 코드로 바꿀꺼임 
        #if data is 'wrong password' or data is 'not exist email' or data is 'no entered event'
        #  deferred.reject data
        #  return
        $window.localStorage.setItem "auth_token", data.Token
        deferred.resolve data
      .error (error,status) ->
        deferred.reject status
    return deferred.promise
  ConfirmEvent: (formData) ->
    deferred = $q.defer()
    this.makeReq('post','enterEvent',formData )
      .success (data) ->
        if data.status < "0"
          deferred.reject data.status
          console.log data
        deferred.resolve data
      .error (error,status) ->
        deferred.reject status
    return deferred.promise
