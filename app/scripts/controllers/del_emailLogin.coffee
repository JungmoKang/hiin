'use strict'

angular.module('hiin')
  .controller 'EmailLoginCtrl', (Util,$scope,$state) ->
    $scope.signIn = ->
      Util.emailLogin($scope.userInfo)
      .then (data) ->
        $state.go('list.events')
      , (status) ->
        console.log status
        console.log 'hi'
        if status == '-2'
          $state.go('signUp')
    return
  return
