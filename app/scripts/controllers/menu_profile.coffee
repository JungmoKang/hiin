'use strict'

angular.module('hiin').controller 'ProfileCtrl', ($rootScope,$scope, Util, Host, socket,upload) ->
  $rootScope.selectedItem = 1
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeAllListeners()
    return  
  $scope.imageUploadUrl = "#{Host.getAPIHost()}:#{Host.getAPIPort()}/profileImage"
  $scope.imagePath = Util.serverUrl()+'/'
  $scope.isEditMode = false
  $scope.btn_edit_or_confirm = 'edit'
  socket.emit "myInfo"
  socket.on "myInfo", (data) ->
    console.log "profile myInfo"
    $scope.userInfo = data
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
angular.module("hiin").directive "ngGender", ($window)->
  link: (scope, element, attrs) ->
    console.log attrs.ngGender
    console.log 'attrs'
    console.dir attrs
    console.log attrs.gender
    if attrs.gender == '0'
      console.log('gender 0')
      scope.gender = 'women'
    else if attrs.gender == '1'
      console.log('gender 1')
      scope.gender = 'men'                                                                                                                      
