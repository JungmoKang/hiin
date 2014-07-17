'use strict'

angular.module('services').factory 'SocketClass', ($q, $window,$ionicModal,$timeout,$state,$rootScope,socket) ->
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
    deferred = $q.defer()
    socket.on options.on, (data)->
      recieved = true
      $timeout ( ->
        options.onCallback(data)
        $timeout.cancel waiting
      ), options.defaultDuration
    if options.emitData 
      socket.emit options.emit, options.emitData
    else
      socket.emit options.emit
    waiting = $timeout (->
      if recieved is yes
        socket.removeListener(options.emit, options.onCallback)
        console.log 'socket suc'
        deferred.resolve 'success'
      else
        socket.removeListener(options.emit, options.onCallback)
        console.log 'error'
        deferred.reject 'fail'
    ), options.duration 
    return deferred.promise
  ###
  parameter
  1.emitName (string) -> socket이름
  2.emitData (onject) -> 서버에 보내는 data 
  3.showLoading (bool) -> Loding 표시
  4.hideLoading (bool) -> 지
  5.defaultDuration -> 응답을 기다리는 시간, 0를 설정할시 100
  6.duration -> 리턴하는 시간 0를 설정할시 1000
  주의!!!
  1. defaultDuration > duration 이어야함
  2. [3]에서 로딩을 표시한후, [4]의 하이드를 하지 않을 경우, 이어서 실행하는 함수에서 반드시 hide해줘야함
  ###
  socketClass: (emitName,emitData,duration,defaultDuration) ->
    class SocketOptions
      _startFunc = ->
        alert 'test'
      _endFunc = null
      constructor: (@emit,@emitData,@duration,@defaultDuration) ->
        @on = @emit
        if @duration is 0
          @duration = 100
        if @defaultDuration is 0
          @defaultDuration = 3000
      onCallback: (data) ->
        throw Error 'unimplemented method'
    return new SocketOptions emitName,emitData,duration,defaultDuration