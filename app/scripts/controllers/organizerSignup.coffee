'use strict'

angular.module('hiin')
  .controller 'OrganizerSignCtrl', (Util,$scope,$state,$window,$q) ->
    #init
    $scope.userInfo = {}
    $scope.userInfo.email = ''
    $scope.userInfo.password = ''
    $scope.errorMsg = '<p> You have entered a wrong
      <p> combo email and password.'
    #공통함수화 해야함
    $scope.back = ->
      $window.history.back()
    $scope.CloseErroMsg = ->
      $scope.showErrMsg = false
    $scope.MakeId = (userInfo) ->
      deferred = $q.defer()
      Util.authReq('post','organizerSignUp', userInfo)
        .success (data) ->
          if data.status < 0
            deferred.reject data
          deferred.resolve data
        .error (data, status) ->
          console.log data
          deferred.reject status
      return deferred.promise    
    $scope.CreateAndSignIn = ->
      if $scope.userInfo.email is '' or ($scope.userInfo.password != $scope.repeat_password)
        $scope.showErrMsg = true
        return
      $scope.MakeId($scope.userInfo)
        .then (data) ->
          $state.go('list.createEvent')
        ,(status) ->
          alert 'err'
      #signup and sign in
    return
  return
