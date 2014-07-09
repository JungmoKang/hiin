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
        $scope.errorMsg = '<p> You have entered a wrong <p> combo email and password.'
    $scope.back = ->
      $window.history.back()
    $scope.GotoResetPassword = ->
      $state.go('resetPassword')
    $scope.CloseErroMsg = ->
      $scope.showErrMsg = false
    return
  return
