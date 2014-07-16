'use strict'

angular.module('hiin').controller 'ProfileCtrl', ($rootScope,$scope, Util, Host, socket,upload,$ionicNavBarDelegate,$window) ->
  $rootScope.selectedItem = 1
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    return
  ionic.DomUtil.ready ->
    $ionicNavBarDelegate.showBackButton(false)
  $scope.imageUploadUrl = "#{Host.getAPIHost()}:#{Host.getAPIPort()}/profileImage"
  $scope.isEditMode = false
  $scope.btn_edit_or_confirm = 'edit'
  $scope.userInfo = JSON.parse($window.localStorage.getItem 'myInfo')
  $scope.edit = ->
    $scope.isEditMode = !$scope.isEditMode
  $scope.cancel = ->
    $scope.isEditMode = false
  $scope.done = ->
    $scope.isEditMode = false
    Util.authReq('post','editUser', $scope.userInfo)
      .success (data) ->
        console.log data
      .error (data, status) ->
        console.log data
  $scope.onSuccess = (response) ->
    console.log "onSucess"
    $scope.userInfo.photoUrl = response.data.photoUrl
    $scope.userInfo.thumbnailUrl = response.data.thumbnailUrl
    return                                                                                                                 
