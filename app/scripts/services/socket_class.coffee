'use strict'

angular.module('services').factory 'SocketClass', ($q, $window,$ionicModal,$timeout,$state,$rootScope,socket,$ionicLoading) ->
  #'options' setting 객체를 만들어서 전달
  #loadingStart, loadingStop은 없으면 그냥 넘어감
  #duration은 ms단위임. 
  #만약 socket.on으로 들어오는 data를 reciece하고 싶다면
  #onCallback내부에서 data로 받는 것을 할당한다.

  #example) options ={
  #         emit : 'ka'
  #         emitData: {
  #            hi: 'hi'
  #         }
  #         on: 'ka'
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
    repeatCount = 0
    deferred = $q.defer()
    if options.showLoadingFlg
      $ionicLoading.show template: "Loading..."
    if options.emitData 
      socket.emit options.emit, options.emitData
    else
      socket.emit options.emit
    socket.on options.on, (data)->
      recieved = true
      options.onCallback(data)
    #duration 시간 안에 응답이 오지 않을 경우, duration에 300ms를 더해서 기다림. 5번 기다려서 오지 않으면 에러
    TimerFunc = ->
      if repeatCount < 4 and recieved is false
        repeatCount = repeatCount + 1
        options.duration = options.duration + 300
        console.log repeatCount
        console.log options.duration
        waiting = $timeout (->
          TimerFunc()
        ), options.duration 
        return
      if recieved
        socket.removeListener(options.emit, options.onCallback)
        console.log 'socket suc'
        $ionicLoading.hide()
        deferred.resolve 'success'
      else
        socket.removeListener(options.emit, options.onCallback)
        console.log 'error'
        $ionicLoading.hide()
        deferred.reject 'fail'
    waiting = $timeout (->
      TimerFunc()
    ), options.duration 
    return deferred.promise
  ###
  parameter
  1.emitName (string) -> socket이름
  2.emitData (onject) -> 서버에 보내는 data 
  3.duration (int) -> 리턴하는 시간, 로딩표시가 on일 경우 디폴트로 1초, 아닐 경우 100ms
  4.showLoadingFlg (bool) -> 로딩 표시
  ###
  socketClass: (emitName,emitData,duration,showLoadingFlg) ->
    class SocketOptions
      constructor: (@emit,@emitData,@duration,@showLoadingFlg) ->
        @on = @emit
        if @duration is 0
          if @showLoadingFlg
            @duration = 1000
          else
            @duration = 100
      onCallback: (data) ->
        throw Error 'unimplemented method'
    return new SocketOptions emitName,emitData,duration,showLoadingFlg