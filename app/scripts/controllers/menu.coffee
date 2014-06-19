'use strict'

angular.module('hiin').controller 'MenuCtrl', ($rootScope,$scope,Util,$window,socket,$state,$modal) ->
  $rootScope.selectedItem = 4
  $scope.TermAndPolish = ->
    $scope.slide = 'slide-left'
    $state.go('termAndPolish')
  $scope.Report = ->
    $scope.slide = 'slide-left'
    $state.go('report')
  $scope.signOut = ->
    modalInstance = $modal.open(
      templateUrl: "views/dialog/logout_notice.html"
      scope: $scope
    )
    modalInstance.result.then ((selectedItem) ->
      $scope.modalInstance = null
      return
    ), ->
      $scope.modalInstance = null
    $scope.modalInstance = modalInstance
  $scope.okay = ->
    console.log 'ok'
    $scope.modalInstance.close()
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
  $scope.cancel = ->
    console.log 'cancel'
    $scope.modalInstance.close()