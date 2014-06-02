"use strict"

angular.module("hiin").controller "SignUpCtrl", ($sce,$q,$http,$scope, $window, Util, Host,socket,$state) ->  
  #init
  $scope.photoUrl = 'images/no_image.jpg'
  $scope.imageUploadUrl = "#{Host.getAPIHost()}:#{Host.getAPIPort()}/profileImage"
  $scope.crop_mode = false
  $scope.CropMode = ->
    if $scope.crop_mode is false
      $scope.crop_mode = true;
      $scope.cropUrl = $sce.trustAsResourceUrl($scope.photoUrl)
    else
      $scope.crop_mode = false;
  $scope.RunCrop = ->
    style = angular.element('#img_crop').find('.jcrop-holder').children()[0].style
    org_image = document.getElementById('img_profile')
    data = 
      url: $scope.userInfo.photoUrl
      top: style.top
      left: style.left
      height: style.height
      width: style.width
      originalHeight: org_image.naturalHeight
      originalWidth: org_image.naturalWidth
    Util.makeReq('post','cropImage',data )
      .success (data) ->
        userInfo.photoUrl = data.photoUrl
        userInfo.thumbnailUrl = data.thumbnailUrl
        $scope.photoUrl = Util.serverUrl() + "/" + data.photoUrl
        $scope.thumbnailUrl = Util.serverUrl() + "/" + data.thumbnailUrl
      .error (error, status) ->
        console.log error
  $scope.onSuccess = (response) ->
    userInfo.photoUrl = response.data.photoUrl
    userInfo.thumbnailUrl = response.data.thumbnailUrl
    $scope.photoUrl = Util.serverUrl() + "/" + response.data.photoUrl
    $scope.thumbnailUrl = Util.serverUrl() + "/" + response.data.thumbnailUrl
    $scope.userInfo = userInfo
  $scope.makeId = (userInfo) ->
    console.log userInfo
    deferred = $q.defer()
    Util.makeReq('post','user', userInfo)
      .success (data) ->
        if data.status < "0"
          deferred.reject data
        deferred.resolve data
      .error (data, status) ->
        console.log data
        deferred.reject status
    return deferred.promise
  $scope.signUp = ->
    $scope.makeId($scope.userInfo)
    .then (data) ->
      $scope.signIn()
    ,(status) ->
      alert 'err'
    return
  $scope.signIn = ->
    Util.emailLogin($scope.userInfo)
    .then (data) ->
      $state.go('enterEvent')
    , (status) ->
      alert status
    return
  $scope.open = ($event) ->
    $event.preventDefault()
    $event.stopPropagation()
    $scope.opened = true
    return
  $scope.dateOptions = 
    'year-format': "'yy'"
    'starting-day': 1
angular.module("hiin").directive "imgCropped", ->
  restrict: "E"
  replace: true
  scope:
    src: "@"
    selected: "&"
  link: (scope, element, attr) ->
    myImg = undefined
    clear = ->
      if myImg
        myImg.next().remove()
        myImg.remove()
        myImg = `undefined`
      return
    scope.$watch "src", (nv) ->
      clear()
      if nv
        element.after "<img />"
        myImg = element.next()
        myImg.attr "src", nv
        $(myImg).Jcrop
          trackDocument: true
          onSelect: (x) ->
            scope.$apply ->
              scope.selected cords: x
              return
            return
          aspectRatio: 1
      return
    scope.$on "$destroy", clear
    return