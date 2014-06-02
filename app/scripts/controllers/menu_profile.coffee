'use strict'

angular.module('hiin').controller 'ProfileCtrl', ($scope, Util, Host, socket,upload) ->
  #scope가 destroy될때, 등록한 이벤트를 모두 지움
  $scope.$on "$destroy", (event) ->
    socket.removeAllListeners()
    return  
  $scope.imagePath = Util.serverUrl()+'/'
  $scope.gender2 = (event) ->
    return event.code isnt $scope.thisEvent.code && event.author isnt $scope.myId.author
  $scope.isNotEdit = true
  $scope.btn_edit_or_confirm = 'edit'
  socket.emit "myInfo"
  socket.on "myInfo", (data) ->
    console.log "profile myInfo"
    $scope.userInfo = data
  $scope.editProfile = ->
    # TODO:캔슬 기능
    if $scope.isNotEdit is true
      $scope.isNotEdit = false
      $scope.btn_edit_or_confirm = 'confirm'
    else
      Util.authReq('post','editUser', $scope.userInfo)
        .success (data) ->
          console.log data
        .error (data, status) ->
          console.log data
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
