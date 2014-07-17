'use strict'

angular.module('hiin').controller 'MenuCtrl', ($rootScope,$scope,Util,$window,socket,$state,$modal,$ionicNavBarDelegate) ->
  console.log 'called menu Ctrl'
  $rootScope.onResume = ->
    console.log "On Resume"
    socket.emit "resume"
    return
  $rootScope.onPause = ->
    console.log "On Pause"
    socket.disconnect()
    return
  if typeof $rootScope.AddFlagPauseHandler  == 'undefined' || $rootScope.AddFlagPauseHandler is false
    document.addEventListener "resume", $rootScope.onResume, false
    document.addEventListener "pause", $rootScope.onPause, false
    $rootScope.AddFlagPauseHandler = true