'use strict'

angular.module('hiin').controller 'MenuCtrl', ($scope,Util,$window,socket,$state) ->
    $scope.TermAndPolish = ->
      $scope.slide = 'slide-left'
      $state.go('termAndPolish')
    $scope.Report = ->
      $scope.slide = 'slide-left'
      $state.go('report')
    $scope.backToList = ->
      $scope.slide = 'slide-right'
      $window.history.back()
    $scope.signOut = ->
      socket.emit "disconnect"
      Util.authReq('get','logout','')
        .success (data) ->
          if data.status is "0"
            console.log 'logout'
            window.localStorage.clearAll()
            $state.go('/')
        .error (error, status) ->
          console.log "error"
