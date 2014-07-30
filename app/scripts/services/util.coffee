'use strict'

angular.module('services').factory 'Util', ($q, $http, $window,$location,$document, Host, Token,$ionicModal,$timeout,$state,$rootScope) ->
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
  MakeId: (userInfo) ->
    console.log userInfo
    deferred = $q.defer()
    userInfo.device = $rootScope.deviceType
    userInfo.deviceToken = $rootScope.deviceToken
    this.makeReq('post','user', userInfo)
      .success (data) ->
        if data.status < "0"
          deferred.reject data
        deferred.resolve data
      .error (data, status) ->
        console.log data
        deferred.reject status
    this.ClearLocalStorage()
    return deferred.promise
  emailLogin: (userInfo) ->
    deferred = $q.defer()
    userInfo.device = $rootScope.deviceType
    userInfo.deviceToken = $rootScope.deviceToken
    console.log userInfo
    this.makeReq('post','login', userInfo )
      .success (data) ->
        if data.status < 0
          deferred.reject data.status
      #TODO:나중에 코드로 바꿀꺼임 
        #if data is 'wrong password' or data is 'not exist email' or data is 'no entered event'
        #  deferred.reject data
        #  return
        $window.localStorage.setItem "auth_token", data.Token
        $window.localStorage.setItem "id_type", 'normal'
        deferred.resolve data
      .error (error,status) ->
        deferred.reject status
    this.ClearLocalStorage()
    return deferred.promise
  userStatus: () ->
    deferred = $q.defer()
    this.authReq('get','userStatus','')
      .success (data) ->
        console.log '-suc-userstatus'
        console.log data
        if data.status < 0
          deferred.reject data.status
        deferred.resolve data
      .error (error,status) ->
        deferred.reject status
    return deferred.promise
  checkOrganizer: () ->
    deferred = $q.defer()
    this.authReq('get','checkOrganizer','')
      .success (data) ->
        console.log '-suc-check organizer'
        console.log data
        if data.status < 0
          deferred.reject data.status
        deferred.resolve data
      .error (error,status) ->
        deferred.reject status
    return deferred.promise
  ConfirmEvent: (formData) ->
    deferred = $q.defer()
    this.authReq('post','enterEvent',formData)
      .success (data) ->
        if data.status < 0
          deferred.reject data.status
          console.log data
        deferred.resolve data
      .error (error,status) ->
        deferred.reject status
    return deferred.promise
  ShowModal : (scope, html_file) ->
    console.log 'show modal'
    $ionicModal.fromTemplateUrl "views/modal/" + html_file + ".html", (($ionicModal) ->
      scope.modal = $ionicModal
      scope.modal.show()
      return
    ),
      scope: scope
      animation: "slide-in-up"
  ClearLocalStorage : () ->
    if $window.localStorage?
      $window.localStorage.clear()
    if window.cordova
      $window.localStorage.setItem "isPhoneGap", "1"
    return
  trimStr : (str, byteSize) ->
    byte = 0
    trimStr = ""
    j = 0
    len = str.length

    while j < len
      (if str.charCodeAt(j) < 0x100 then byte++ else byte += 2)
      trimStr += str.charAt(j)
      if byte >= byteSize
        trimStr = trimStr.substr(0, j - 2) + "..."
        break
      j++
    trimStr