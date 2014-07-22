angular.module('hiin').controller 'NoticeCtrl', ($rootScope,$scope,Util,$window,socket,$state,$modal,$ionicNavBarDelegate,$stateParams) ->
  $rootScope.selectedItem = 5
  if $rootScope.previousState is 'list.groupChat'
    $scope.fromMenu = false
  else
    $scope.fromMenu = true
  ionic.DomUtil.ready ->
    $ionicNavBarDelegate.showBackButton(false)
  $scope.Back = ->
    console.log 'back'
    $window.history.back()
