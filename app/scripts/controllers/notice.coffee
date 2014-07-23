angular.module('hiin').controller 'NoticeCtrl', ($rootScope,$scope,Util,$window,socket,$state,$modal,$ionicNavBarDelegate,$stateParams) ->  
  ionic.DomUtil.ready ->
    $ionicNavBarDelegate.showBackButton(false)
  $scope.Back = ->
    console.log 'back'
    $window.history.back()
