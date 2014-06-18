(function() {
  "use strict";
  angular.module("hiin", ["ionic", "hiin.controllers", "ngRoute", "services", "filters", "btford.socket-io", "ui.bootstrap", "lr.upload", "ui.date"]).config(function($stateProvider, $urlRouterProvider) {
    $stateProvider.state("/", {
      url: "/",
      templateUrl: "views/login/login.html",
      controller: "LoginCtrl"
    }).state("emailLogin", {
      url: "/emailLogin",
      templateUrl: "views/login/email_login.html",
      controller: "EmailLoginCtrl"
    }).state("signUp", {
      url: "/signUp",
      templateUrl: "views/login/signup.html",
      controller: "SignUpCtrl"
    }).state('list', {
      url: '/list',
      abstract: true,
      templateUrl: 'views/menu/menu.html',
      controller: 'MenuCtrl'
    }).state("list.userlists", {
      url: "/userlists",
      views: {
        menuContent: {
          templateUrl: "views/list/list.html",
          controller: "ListCtrl"
        }
      }
    }).state("list.single", {
      url: "/userlists/:userId",
      views: {
        menuContent: {
          templateUrl: "views/chat/chat_room.html",
          controller: "chatCtrl"
        }
      }
    }).state("list.groupChat", {
      url: "/groupChat",
      views: {
        menuContent: {
          templateUrl: "views/chat/chat_room.html",
          controller: "grpChatCtrl"
        }
      }
    }).state("list.activity", {
      url: "/activity",
      views: {
        menuContent: {
          templateUrl: "views/list/activity.html",
          controller: "ActivityCtrl"
        }
      }
    }).state("list.eventInfo", {
      url: "/eventInfo",
      views: {
        menuContent: {
          templateUrl: "views/event/info_event.html",
          controller: "eventInfoCtrl"
        }
      }
    }).state("list.profile", {
      url: "/profile",
      views: {
        menuContent: {
          templateUrl: "views/menu/profile.html",
          controller: "ProfileCtrl"
        }
      }
    }).state("list.setting", {
      url: "/setting",
      views: {
        menuContent: {
          templateUrl: "views/menu/setting.html",
          controller: "MenuCtrl"
        }
      }
    }).state("list.events", {
      url: "/events",
      views: {
        menuContent: {
          templateUrl: "views/menu/events.html",
          controller: "MenuEventCtrl"
        }
      }
    }).state("list.createEvent", {
      url: "/createEvent",
      views: {
        menuContent: {
          templateUrl: "views/event/create_event.html",
          controller: "CreateEventCtrl"
        }
      }
    }).state("list.termAndPolish", {
      url: "/termAndPolish",
      views: {
        menuContent: {
          templateUrl: "views/menu/term_and_polish.html",
          controller: "MenuCtrl"
        }
      }
    }).state("list.report", {
      url: "/report",
      views: {
        menuContent: {
          templateUrl: "views/menu/report.html",
          controller: "MenuCtrl"
        }
      }
    });
    $urlRouterProvider.otherwise("/");
  }).config(function($httpProvider) {
    $httpProvider.defaults.transformRequest = function(data) {
      if (data === undefined) {
        return data;
      }
      return $.param(data);
    };
    return $httpProvider.defaults.withCredentials = true;
  });

  angular.module("hiin").run(function($window, Migration) {
    $window.localDb = $window.openDatabase("hiin", "1.0", "hiin DB", 1000000);
    Migration.apply($window.localDb);
  });

}).call(this);
