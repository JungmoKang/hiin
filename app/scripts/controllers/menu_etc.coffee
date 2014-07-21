angular.module('hiin').controller 'MenuCtrlEtc', ($rootScope,$scope,Util,$window,socket,$state,$modal,$ionicNavBarDelegate) ->
  $rootScope.selectedItem = 4
  ionic.DomUtil.ready ->
    $ionicNavBarDelegate.showBackButton(false)
  $scope.TermAndPolish = ->
    $scope.slide = 'slide-left'
    $state.go('list.termAndPolish')
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
          socket.disconnect()
          $window.localStorage.setItem "socket_disconnect", '1'
          $state.go('/')
      .error (error, status) ->
        console.log "error"
  $scope.cancel = ->
    console.log 'cancel'
    $scope.modalInstance.close()
  $scope.Back = ->
    $window.history.back()