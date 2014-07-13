"use strict"
# Ionic Starter App
# angular.module is a global place for creating, registering and retrieving Angular modules
angular.module("hiin", [
  "ionic"
  "ngRoute"
  "services"
  "filters"
  "btford.socket-io"
  "ui.bootstrap"
  "lr.upload"
])
.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider
  .state("/",
    url: "/"
    templateUrl: "views/login/login.html"
    controller: "LoginCtrl"
  )
  .state("signin",
    url: "/signin"
    templateUrl: "views/login/signin.html"
    controller: "SignInCtrl"
  )
  .state("organizerLogin",
    url: "/organizerLogin"
    templateUrl: "views/login/organizer_login.html"
    controller: "OrganizerLoginCtrl"
  )
  .state("resetPassword",
    url: "/resetPassword"
    templateUrl: "views/login/reset_password.html"
    controller: "OrganizerLoginCtrl"
  )
  .state('list', 
    url: '/list'
    abstract: true
    templateUrl: 'views/menu/menu.html'
    controller: 'MenuCtrl'
  )
  .state("list.userlists",
    url: "/userlists"
    views:
      menuContent:
        templateUrl: "views/list/list.html"
        controller: "ListCtrl"
  )
  .state("list.single",
    url: "/userlists/:userId"
    views:
      menuContent:
        templateUrl: "views/chat/chat_room.html"
        controller: "chatCtrl"
  )
  .state("list.groupChat",
    url: "/groupChat"
    views:
      menuContent:
        templateUrl: "views/chat/chat_room.html"
        controller: "grpChatCtrl"
  )
  .state("list.activity",
    url: "/activity"
    views:
      menuContent:
        templateUrl: "views/list/activity.html"
        controller: "ActivityCtrl"
  )
  .state("list.eventInfo",
    url: "/eventInfo"
    views:
      menuContent:
        templateUrl: "views/event/info_event.html"
        controller: "eventInfoCtrl"
  )
  .state("list.profile",
    url: "/profile"
    views:
      menuContent:
        templateUrl: "views/menu/profile.html"
        controller: "ProfileCtrl"
  )
  .state("list.setting",
    url: "/setting"
    views:
      menuContent:
        templateUrl: "views/menu/setting.html"
        controller: "MenuCtrl"
  )
  .state("list.events",
    url: "/events"
    views:
      menuContent:
        templateUrl: "views/menu/events.html"
        controller: "MenuEventCtrl"
  )
  .state("list.createEvent",
    url: "/createEvent"
    views:
      menuContent:
        templateUrl: "views/event/create_event.html"
        controller: "CreateEventCtrl"
  )
  .state("list.organizerSignUp",
    url: "/organizerSignUp"
    views:
      menuContent:
        templateUrl: "views/login/organizer_signup.html"
        controller: "OrganizerSignCtrl"
  )
  .state("list.organizerLogin",
    url: "/organizerLogin"
    views:
      menuContent:
        templateUrl: "views/login/organizerLoginFromEventPage.html"
        controller: "OrganizerSignCtrl"
  )
  .state("list.termAndPolish",
    url: "/termAndPolish"
    views:
      menuContent:
        templateUrl: "views/menu/term_and_polish.html"
        controller: "MenuCtrl"
  )
  .state("list.report",
    url: "/report"
    views:
      menuContent:
        templateUrl: "views/menu/report.html"
        controller: "MenuCtrl"
  ) 
  $urlRouterProvider.otherwise "/"
  return
.config ($httpProvider) ->
    $httpProvider.defaults.transformRequest = (data) ->
      return data  if data is `undefined`
      $.param data
    $httpProvider.defaults.withCredentials = true

angular.module("hiin").run ($window,  Migration,　$rootScope) ->
  # prepare database 
  $window.localDb = $window.openDatabase "hiin", "1.0", "hiin DB", 1000000
  Migration.apply $window.localDb
  tokenHandler = (result) ->
    console.log "deviceToken:" + result
    $rootScope.deviceToken = result
    console.log "rootscope device token" + $rootScope.deviceToken
    return
  errorHandler = (err) ->
    console.log "error:" + err
    return
  successHandler = (result) ->
    console.log "result:" + result
    return
  onNotificationAPN = (event) ->
    # 푸시 메세지에 alert 값이 있을 경우
    navigator.notification.alert event.alert  if event.alert
    # 푸시 메세지에 sound 값이 있을 경우
    if event.sound
      snd = new Media(event.sound)
      snd.play()
    # 푸시 메세지에 bage 값이 있을 경우
    window.plugins.pushNotification.setApplicationIconBadgeNumber successHandler, errorHandler, event.badge  if event.badge
    return
  # 디바이스가 ready가 될때 실행될 수 있도록 이벤트 리스너에 등록한다.
  document.addEventListener "deviceready", ->
    console.log "DeviceReady"
    # PushPlugin을 설치했다면 window.plugins.pushNotification.register를 이용해서 iOS 푸시 서비스를 등록한다.
    window.plugins.pushNotification.register tokenHandler, errorHandler,
      badge: "true" # 뱃지 기능을 사용한다.
      sound: "true" # 사운드를 사용한다.
      alert: "true" # alert를 사용한다.
      ecb: "onNotificationAPN" # 디바이스로 푸시가 오면 onNotificationAPN 함수를 실행할 수 있도록 ecb(event callback)에 등록한다.
    return