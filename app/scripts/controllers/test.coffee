"use strict"

# Called to navigate to the main app

# Called each time the slide changes
angular.module("hiin.controllers", []).controller("IntroCtrl", ($scope, $state, $ionicSlideBoxDelegate) ->
  $scope.startApp = ->
    $state.go "main"
    return

  $scope.next = ->
    $ionicSlideBoxDelegate.next()
    return

  $scope.previous = ->
    $ionicSlideBoxDelegate.previous()
    return

  $scope.slideChanged = (index) ->
    $scope.slideIndex = index
    return

  return
).controller "MainCtrl", ($scope, $state) ->
  console.log "MainCtrl"
  $scope.toIntro = ->
    $state.go "intro"
    return

  return
