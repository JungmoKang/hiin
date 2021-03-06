'use strict'

angular.module('hiin')
  .controller 'SignInCtrl', ($modal,$sce,$q,$http,$scope, $window, Util, Host,$state,$timeout,$ionicLoading) ->  
    #init
    $scope.userInfo = {}
    $scope.userInfo.gender = 1
    $scope.userInfo.photoUrl = ''
    $scope.userInfo.thumbnailUrl = ''
    $scope.photoUrl = 'images/no_image.jpg'
    $scope.imageUploadUrl = "#{Host.getAPIHost()}:#{Host.getAPIPort()}/profileImage"
    $scope.ToggleGender = (gender) ->
      $scope.userInfo.gender = gender
    $scope.back = ->
      $window.history.back()
    $scope.onSuccess = (response) ->
      console.log "onSucess"
      console.log response
      if $scope.userInfo?
        userInfo = $scope.userInfo
      else
        userInfo = {}
        userInfo.gender = 1
      userInfo.photoUrl = response.data.photoUrl
      userInfo.thumbnailUrl = response.data.thumbnailUrl
      $scope.photoUrl = Util.serverUrl() + "/" + response.data.photoUrl
      $scope.thumbnailUrl = Util.serverUrl() + "/" + response.data.thumbnailUrl
      $scope.userInfo = userInfo
      angular.element('img.image_upload_btn').attr("src", $scope.thumbnailUrl)
      return
    $scope.onUpload = (files) ->
      $ionicLoading.show template: "Uploading..."
    $scope.onError = (response) ->
      alert 'Image Upload error'
      console.log 'error'
    $scope.onComplete = (response) ->
      $ionicLoading.hide()
    $scope.SignUp = (isValid) ->
      console.log isValid
      if $scope.userInfo.photoUrl is ""
        if $scope.userInfo.gender is 1
          $scope.userInfo.photoUrl = "profileImageOriginal/female.png"
          $scope.userInfo.thumbnailUrl = "profileImageThumbnail/female.png"
        else
          $scope.userInfo.photoUrl = "profileImageOriginal/male.png"
          $scope.userInfo.thumbnailUrl = "profileImageThumbnail/male.png"
      if isValid == true
        Util.MakeId($scope.userInfo)
          .then (data) ->
            console.log data
            console.log '---return make Id---'
            $window.localStorage.setItem "auth_token", data.Token
            $window.localStorage.setItem "id_type", 'normal'
            $scope.signIn()
          ,(status) ->
            alert 'err'
          return
      else
        return $scope.showAlert()
    $scope.signIn = ->
      Util.userStatus()
        .then (data) ->
          console.log console.log '---return userStatus---'
          console.log data
          $state.go('list.events')
        , (status) ->
          alert status
      return
    $scope.open = ($event) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope.opened = true
      return
    $scope.showAlert = ->
      modalInstance = $modal.open(
        templateUrl: "views/login/alert.html"
        scope: $scope
      )
