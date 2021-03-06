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
  .state("list.createEventPc",
    url: "/createEventPc"
    views:
      menuContent:
        templateUrl: "views/event/create_event_pc.html"
        controller: "CreateEventCtrlPc"
  )
  .state("list.createEventAndroid",
    url: "/createEventAndroid"
    views:
      menuContent:
        templateUrl: "views/event/create_event_android.html"
        controller: "CreateEventCtrlAndroid"
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
        controller: "OrganizerLoginCtrl"
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

angular.module("hiin").run ($window,  Migration,　$rootScope,Util, $filter, $state) ->
  ###
  $rootScope.$on "$stateChangeSuccess", (ev, to, toParams, from, fromParams) ->
    $rootScope.previousState = from.name
    $rootScope.currentState = to.name
    console.log "Previous state:" + $rootScope.previousState
    console.log "Current state:" + $rootScope.currentState
    return
  ###
  # prepare database 
  $rootScope.deviceType = "web"
  $rootScope.version = "0.1.0"
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
  if navigator.userAgent.indexOf('iPhone') > 0
    $rootScope.browser = 'ios'
  else if navigator.userAgent.indexOf('Android') > 0
    $rootScope.browser = 'android'
    $("body").height($("body").height())
  else
    $rootScope.browser = 'pc'
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
  $window.onNotificationAPN = (event) ->
    console.log 'onNotificationAPN'
    console.log event
    sleepFlg = $window.localStorage.getItem "sleep"
    console.log sleepFlg
    if sleepFlg is 'false' or event.foreground is '1'
      console.log 'cancel'
      return
    $rootScope.$broadcast("pushed", event)
    navigator.notification.alert event.alert,'Hiin'
    if event.sound
      snd = new Media(event.sound)
      snd.play()
    pushNotification.setApplicationIconBadgeNumber successHandler, errorHandler, event.badge  if event.badge
    return
  $window.onNotification = (e) ->
    console.log 'get notification'
    switch e.event
      when "registered"
        if e.regid.length > 0
          console.log "regID = " + e.regid
          $rootScope.deviceToken = e.regid
      when "message"
        sleepFlg = $window.localStorage.getItem "sleep"
        console.log sleepFlg
        if sleepFlg is 'false' or e.foreground
          navigator.notification.alert e.message,'Hiin'
          console.log 'cancel'
          return
        #soundfile = e.soundname or e.payload.sound
          # if the notification contains a soundname, play it.
        #my_media = new Media("/android_asset/www/" + soundfile)
        #my_media.play()
        $rootScope.$broadcast("pushed", e)
      when "error"
        console.log "error"
      else
        console.log "unknown"
  document.addEventListener "deviceready", ->
    console.log "DeviceReady"
    pushNotification = window.plugins.pushNotification
    cordova.getAppVersion().then (version) ->
      $rootScope.version = version
      console.log version
    if typeof device  is 'undefined' or device is null
      $rootScope.deviceType = 'web'
    else if device.platform is "android" or device.platform is "Android"
      console.log 'device type is android'
      $rootScope.deviceType = 'android'
      pushNotification.register successHandler, errorHandler,
        senderID: "605768570066"
        ecb: "window.onNotification"
    else
      console.log 'device type is ios'
      $rootScope.deviceType = 'ios'
      pushNotification.register tokenHandler, errorHandler,
        badge: "true"
        sound: "true"
        alert: "true"
        ecb: "window.onNotificationAPN"
