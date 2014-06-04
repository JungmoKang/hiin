"use strict"

# Ionic Starter App

# angular.module is a global place for creating, registering and retrieving Angular modules
angular.module("hiin", [
  "ionic"
  "hiin.controllers"
  "ngRoute"
  "services"
  "filters"
  "btford.socket-io"
  "ui.bootstrap"
  "lr.upload"
  "ui.date"
  "flow"
])
.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider
  .state("/",
    url: "/"
    templateUrl: "views/login/login.html"
    controller: "LoginCtrl"
  )
  .state("intro",
    url: "/intro"
    templateUrl: "views/main/intro.html"
    controller: "IntroCtrl"
  )
  .state("main",
    url: "/main"
    templateUrl: "views/main/main.html"
    controller: "MainCtrl"
  )
  .state("emailLogin",
    url: "/emailLogin"  
    templateUrl: "views/login/email_login.html"
    controller: "EmailLoginCtrl"
  )
  .state("enterEvent",
    url: "/enterEvent"
    templateUrl: "views/event/confirm_event.html"
    controller: "eventCtrl"
  )
  .state("signUp",
    url: "/signUp"
    templateUrl: "views/login/signup.html"
    controller: "SignUpCtrl"
  )
  .state("createEvent",
    url: "/createEvent"
    templateUrl: "views/event/create_event.html"
    controller: "CreateEventCtrl"
  )
  .state("createEventAttention",
    url: "/createEventAttention"
    templateUrl: "views/event/attention.html"
    controller: "CreateEventCtrl"      
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
