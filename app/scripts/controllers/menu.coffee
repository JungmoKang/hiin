'use strict'

angular.module('hiin').controller 'MenuCtrl', ($rootScope,$scope,Util,$window,socket,$state) ->
  $rootScope.selectedItem = 4
  $scope.TermAndPolish = ->
    $scope.slide = 'slide-left'
    $state.go('termAndPolish')
  $scope.Report = ->
    $scope.slide = 'slide-left'
    $state.go('report')
  $scope.signOut = ->
    socket.emit "disconnect"
    Util.authReq('get','logout','')
      .success (data) ->
        if data.status is "0"
          console.log 'logout'
          if $window.localStorage?
            $window.localStorage.clear()
          $state.go('/')
      .error (error, status) ->
        console.log "error"
