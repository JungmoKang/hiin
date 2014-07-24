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
  .state("list.notice",
    url: "/notice"
    views:
      menuContent:
        templateUrl: "views/chat/notice.html"
        controller: "NoticeCtrl"
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
        controller: "MenuCtrlEtc"
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
        controller: "MenuCtrlEtc"
  )
  .state("list.report",
    url: "/report"
    views:
      menuContent:
        templateUrl: "views/menu/report.html"
        controller: "MenuCtrlEtc"
  ) 
  $urlRouterProvider.otherwise "/"
  return
.config ($httpProvider) ->
    $httpProvider.defaults.transformRequest = (data) ->
      return data  if data is `undefined`
      $.param data
    $httpProvider.defaults.withCredentials = true

angular.module("hiin").run ($window,  Migration,　$rootScope,Util,$filter) ->
  ###
  $rootScope.$on "$stateChangeSuccess", (ev, to, toParams, from, fromParams) ->
    $rootScope.previousState = from.name
    $rootScope.currentState = to.name
    console.log "Previous state:" + $rootScope.previousState
    console.log "Current state:" + $rootScope.currentState
    return
  ###
  # prepare database 
  $rootScope.ShowProfileImage = (userInfo) ->
    console.log userInfo
    $rootScope.imgUrl = $filter('profileImage')(userInfo.photoUrl)
    Util.ShowModal($rootScope,'profile_image')
  $rootScope.Close = ->
    $rootScope.modal.hide()
    $rootScope.modal.remove()
  $window.localDb = $window.openDatabase "hiin", "1.0", "hiin DB", 1000000
  Migration.apply $window.localDb
  pushNotification = ''
  $rootScope.deviceType = 'web'
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
    navigator.notification.alert event.alert  if event.alert
    if event.sound
      snd = new Media(event.sound)
      snd.play()
    pushNotification.setApplicationIconBadgeNumber successHandler, errorHandler, event.badge  if event.badge
    return
  onNotification = (e) ->
    switch e.event
      when "registered"
        if e.regid.length > 0
          console.log "regID = " + e.regid
          $rootScope.deviceToken = e.regid
      when "message"
        # if this flag is set, this notification happened while we were in the foreground.
        # you might want to play a sound to get the user's attention, throw up a dialog, etc.
        if e.foreground
          # on Android soundname is outside the payload. 
          # On Amazon FireOS all custom attributes are contained within payload
          soundfile = e.soundname or e.payload.sound
          # if the notification contains a soundname, play it.
          my_media = new Media("/android_asset/www/" + soundfile)
          my_media.play()
        else # otherwise we were launched because the user touched a notification in the notification tray.
      when "error"
        console.log "error"
      else
        console.log "unknown"
  document.addEventListener "deviceready", ->
    console.log "DeviceReady"
    pushNotification = window.plugins.pushNotification
    $rootScope.deviceToken = ''
    if typeof device  is 'undefined' or device is null
      $rootScope.deviceType = 'web'
    else if device.platform is "android" or device.platform is "Android"
      console.log 'device type is android'
      $rootScope.deviceType = 'android'
      pushNotification.register successHandler, errorHandler,
        senderID: "hiin-push-server"
        ecb: "onNotification"
    else
      console.log 'device type is ios'
      $rootScope.deviceType = 'ios'
      pushNotification.register tokenHandler, errorHandler,
        badge: "true"
        sound: "true"
        alert: "true"
        ecb: "onNotificationAPN"
