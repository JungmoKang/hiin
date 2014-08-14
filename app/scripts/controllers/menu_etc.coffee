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
    Util.checkOrganizer()
      .then (data) ->
        console.log '---organizer state----'
        if data.status == "0"
          # 오거나이저
          $scope.message = "<p>are you sure to 
             <p>log out?"
        else if data.status == "1"
          $scope.message = "<p>Your account infomation
          <p>(profile, chat history, activity log)
             <p>will be permanently deleted
             <p>when you log out."
          # 일반유저
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