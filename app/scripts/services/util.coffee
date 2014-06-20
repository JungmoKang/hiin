'use strict'

angular.module('services').factory 'Util', ($q, $http, $window,$location,$document, Host, Token,$ionicModal) ->
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
      #TODO:나중에 코드로 바꿀꺼임 
        #if data is 'wrong password' or data is 'not exist email' or data is 'no entered event'
        #  deferred.reject data
        #  return
        $window.localStorage.setItem "auth_token", data.Token
        deferred.resolve data
      .error (error,status) ->
        deferred.reject status
    return deferred.promise
  userStatus: () ->
    deferred = $q.defer()
    this.authReq('get','userStatus','')
      .success (data) ->
        console.log '-suc-userstatus'
        console.log data
        if data.status != "0"
          deferred.reject data.status
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
  ShowModal : (scope, html_file) ->
    console.log 'show modal'
    $ionicModal.fromTemplateUrl "views/modal/" + html_file + ".html", (($ionicModal) ->
      scope.modal = $ionicModal
      scope.modal.show()
      return
    ),
      scope: scope
      animation: "slide-in-up"
  #'options' setting 객체를 만들어서 전달
  #loadingStart, loadingStop은 없으면 그냥 넘어감
  #duration은 ms단위임. 
  #만약 socket.on으로 들어오는 data를 reciece하고 싶다면
  #onCallback내부에서 data로 받는 것을 할당한다.

  #example) options ={
  #         emit : 'ka'
  #         emitData: {
  #            hi: 'hi'
  #        }
  #       on: 'ka'
  #       onCallback: (data)->
  #         console.log 'calcalcal'
  #       loadingStart: ()->
  #         console.log 'loading now'
  #       loadingstop: ()->
  #         console.log 'loading stop'
  #        duration: 3000
  #        defaultDuration: 1000
  # }

  resSocket: (options)->
    recieved = false
    deferred = $q.defer()
    socket.on options.on, (data)->
      recieved = true
      $timeout ( ->
        options.onCallback(data)
        $timeout.cancel waiting
        if options.loadingstop
          options.loadingstop()
      ), options.defaultDuration
      return
    if options.loadingStart
      options.loadingStart()
    if options.emit 
      socket.emit options.emit, options.emit
    else
      socket.emit options.emit

    waiting = $timeout (->
      if recieved is yes
        deferred.resolve 'success'
      else
        deferred.reject 'fail'
      return
    ), options.duration 

    return deferred.promise
