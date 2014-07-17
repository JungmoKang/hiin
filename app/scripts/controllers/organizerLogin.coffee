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
        $scope.msgHeaderShow = true
        $scope.headerMsg = '<p> You have entered a wrong <p> combo email and password.'
        $scope.msgHeaderClass = 'error_panel'
    $scope.back = ->
      $window.history.back()
    $scope.GotoResetPassword = ->
      $state.go('resetPassword')
    $scope.CloseHeaderMsg = ->
      $scope.msgHeaderShow = false
    return
  return
