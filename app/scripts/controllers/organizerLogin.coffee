'use strict'

angular.module('hiin')
  .controller 'OrganizerLoginCtrl', (Util,$scope,$state,$window) ->
    $scope.Login = ->
      Util.emailLogin($scope.userInfo)
      .then (data) ->
        $state.go('list.events')
      , (status) ->
        console.log status
        console.log 'error'
        $scope.showErrMsg = true
    $scope.back = ->
      $window.history.back()
    $scope.GotoResetPassword = ->
      $state.go('resetPassword')
    $scope.ResetPassword = ->
      #reset
    $scope.CloseErroMsg = ->
      $scope.showErrMsg = false
    $scope.CreateAndSignIn = ->
      #signup and sign in
    $scope.organizerLogin = ->
      $state.go('list.organizerLogin')
    $scope.SignIn = ->
      #signin
    return
  return
