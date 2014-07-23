'use strict'

angular.module('hiin').controller 'ProfileCtrl', ($rootScope,$ionicLoading,$scope, Util, Host,$ionicNavBarDelegate,$window,SocketClass) ->
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
  MakeMyInfoOptionObj = () ->
    socketMyInfo = new SocketClass.socketClass('myInfo',null,0,true)
    socketMyInfo.onCallback = (data) ->
      console.log "list myInfo"
      console.log data
      $scope.userInfo = data
      $window.localStorage.setItem 'myInfo', JSON.stringify(data)
      return
    return socketMyInfo
  $scope.edit = ->
    $scope.isEditMode = !$scope.isEditMode
  $scope.cancel = ->
    $scope.isEditMode = false
  $scope.done = ->
    $scope.isEditMode = false
    Util.makeReq('post','editUser', $scope.userInfo)
      .success (data) ->
        SocketClass.resSocket(MakeMyInfoOptionObj())
          .then (data) ->
            console.log 'socket got myInfo'
          , (status) ->
            console.log "error"
        console.log data
      .error (data, status) ->
        console.log data
  $scope.onSuccess = (response) ->
    console.log "onSucess"
    $scope.userInfo.photoUrl = response.data.photoUrl
    $scope.userInfo.thumbnailUrl = response.data.thumbnailUrl
    return                                                                                                                 
  $scope.onUpload = (files) ->
    $ionicLoading.show template: "Uploading..."
  $scope.onError = (response) ->
    alert 'Image Upload error'
    console.log 'error'
  $scope.onComplete = (response) ->
    console.log 'complete'
    $ionicLoading.hide()