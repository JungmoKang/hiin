'use strict';

// AngularJS 에서 module을 정의할 때 뒤에 dependecy list를 주게 되면 새로운 module을 정의하겠다는 소리고
// 단순히 angular.module('services') 하게 되면 기존에 만들어진 module을 refer하겠다는 의미임.

// services 라는 모듈 선언
angular.module('services', [])
  // API_PORT를 상수로 정의. API_PORT는 나중에 dependency injection에서 쓰일 수 있음.
  .constant('API_PORT', 3000)
  // API_HOST를 상수로 정의.
  //.constant('API_HOST', "http://192.168.0.26");
  //.constant('API_HOST', "http://192.168.11.4");
  //.constant('API_HOST', "http://sdent.kr");
  .constant('API_HOST', "http://localhost");
  

(function() {
  angular.module('services').factory('Token', function($q, $http, $window, $location, Host) {
    if ($window.localStorage == null) {
      alert("$window.localStorage doesn't exist");
    }
    return {
      authToken: function() {
        return $window.localStorage.getItem("auth_token");
      }
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module("filters", []).filter("gender", function() {
    return function(input) {
      if (input === '1') {
        return "Male";
      } else {
        return "Female";
      }
    };
  });

}).call(this);

(function() {
  angular.module('services').factory('Host', function($window, API_HOST, API_PORT) {
    var host, _API_HOST, _API_PORT;
    _API_HOST = API_HOST;
    if ($window.localStorage != null) {
      host = $window.localStorage.getItem("api_host");
      console.log("localstorage host = " + host);
      if (host && host !== "") {
        _API_HOST = host;
      }
    }
    _API_PORT = API_PORT;
    return {
      getAPIHost: function() {
        return _API_HOST;
      },
      getAPIPort: function() {
        return _API_PORT;
      },
      setAPIPort: function(port) {
        console.log("set api port! host = " + port);
        return _API_PORT = port;
      }
    };
  });

}).call(this);

(function() {
  angular.module('services').factory('imageReader', function($q, $log) {
    var getReader, onError, onLoad, onProgress, readAsDataURL;
    onLoad = function(reader, deferred, scope) {
      return function() {
        scope.$apply(function() {
          deferred.resolve(reader.result);
        });
      };
    };
    onError = function(reader, deferred, scope) {
      return function() {
        scope.$apply(function() {
          deferred.reject(reader.result);
        });
      };
    };
    onProgress = function(reader, scope) {
      return function(event) {
        scope.$broadcast("fileProgress", {
          total: event.total,
          loaded: event.loaded
        });
      };
    };
    getReader = function(deferred, scope) {
      var reader;
      reader = new FileReader();
      reader.onload = onLoad(reader, deferred, scope);
      reader.onerror = onError(reader, deferred, scope);
      reader.onprogress = onProgress(reader, scope);
      return reader;
    };
    readAsDataURL = function(file, scope) {
      var deferred, reader;
      deferred = $q.defer();
      reader = getReader(deferred, scope);
      reader.readAsDataURL(file);
      return deferred.promise;
    };
    return {
      readAsDataUrl: readAsDataURL
    };
  });

}).call(this);

(function() {
  angular.module('services').factory('socket', function(socketFactory, Host) {
    var myIoSocket, mySocket;
    myIoSocket = io.connect("" + (Host.getAPIHost()) + ":" + (Host.getAPIPort()) + "/hiin");
    mySocket = socketFactory({
      ioSocket: myIoSocket
    });
    return mySocket;
  });

}).call(this);

(function() {
  'use strict';
  angular.module('services').factory('Util', function($q, $http, $window, $location, $document, Host, Token) {
    return {
      serverUrl: function() {
        return "" + (Host.getAPIHost()) + ":" + (Host.getAPIPort());
      },
      makeReq: function(method, path, param) {
        console.log("" + (Host.getAPIHost()) + ":" + (Host.getAPIPort()) + "/" + path);
        return $http[method]("" + (Host.getAPIHost()) + ":" + (Host.getAPIPort()) + "/" + path, (method === "get" ? {
          params: param
        } : param), {
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
          }
        });
      },
      authReq: function(method, path, param, options) {
        var opts;
        if (options == null) {
          options = {};
        }
        if (options.headers == null) {
          options.headers = {};
        }
        options.headers["Authorization"] = "" + (Token.authToken());
        options.headers["Content-Type"] = 'application/x-www-form-urlencoded';
        opts = {};
        if (method === "get") {
          opts = {
            method: "get",
            url: "" + (Host.getAPIHost()) + ":" + (Host.getAPIPort()) + "/" + path,
            params: param
          };
        } else {
          opts = {
            method: method,
            url: "" + (Host.getAPIHost()) + ":" + (Host.getAPIPort()) + "/" + path,
            data: param
          };
        }
        opts = angular.extend(opts, options);
        return $http(opts);
      },
      emailLogin: function(userInfo) {
        var deferred;
        deferred = $q.defer();
        this.makeReq('post', 'login', userInfo).success(function(data) {
          if (data.status !== "0") {
            deferred.reject(data.status);
            console.log(data);
          }
          $window.localStorage.setItem("auth_token", data.Token);
          return deferred.resolve(data);
        }).error(function(error, status) {
          return deferred.reject(status);
        });
        return deferred.promise;
      },
      ConfirmEvent: function(formData) {
        var deferred;
        deferred = $q.defer();
        this.makeReq('post', 'enterEvent', formData).success(function(data) {
          if (data.status < "0") {
            deferred.reject(data.status);
            console.log(data);
          }
          return deferred.resolve(data);
        }).error(function(error, status) {
          return deferred.reject(status);
        });
        return deferred.promise;
      }
    };
  });

}).call(this);

(function() {
  "use strict";
  angular.module("hiin", ["ionic", "hiin.controllers", "ngRoute", "services", "filters", "btford.socket-io", "ui.bootstrap", "lr.upload", "ui.date"]).config(function($stateProvider, $urlRouterProvider) {
    $stateProvider.state("/", {
      url: "/",
      templateUrl: "views/login/login.html",
      controller: "LoginCtrl"
    }).state("intro", {
      url: "/intro",
      templateUrl: "views/main/intro.html",
      controller: "IntroCtrl"
    }).state("main", {
      url: "/main",
      templateUrl: "views/main/main.html",
      controller: "MainCtrl"
    }).state("emailLogin", {
      url: "/emailLogin",
      templateUrl: "views/login/email_login.html",
      controller: "EmailLoginCtrl"
    }).state("enterEvent", {
      url: "/enterEvent",
      templateUrl: "views/event/confirm_event.html",
      controller: "eventCtrl"
    }).state("signUp", {
      url: "/signUp",
      templateUrl: "views/login/signup.html",
      controller: "SignUpCtrl"
    }).state("createEvent", {
      url: "/createEvent",
      templateUrl: "views/event/create_event.html",
      controller: "CreateEventCtrl"
    }).state("createEventAttention", {
      url: "/createEventAttention",
      templateUrl: "views/event/attention.html",
      controller: "CreateEventCtrl"
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

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('ActivityCtrl', function($scope, $rootScope, $window, Util, socket, $modal) {
    socket.emit("activity");
    $scope.$on("$destroy", function(event) {
      socket.removeAllListeners();
    });
    socket.emit("myInfo");
    socket.on("myInfo", function(data) {
      console.log("list myInfo");
      $scope.myInfo = data;
      $scope.imagePath = Util.serverUrl() + '/';
    });
    socket.on("activity", function(data) {
      $scope.rank = data.rank;
      $scope.activitys = data.activity;
      console.log("activity");
      return console.log(data);
    });
    $scope.okay = function() {
      return console.log('ih');
    };
    $scope.backToList = function() {
      $scope.slide = 'slide-right';
      return $window.history.back();
    };
    $scope.showRank = function() {
      var modalInstance;
      return modalInstance = $modal.open({
        templateUrl: "views/list/rank_modal.html",
        scope: $scope
      });
    };
    $scope.ShowProfile = function(user) {
      var modalInstance;
      console.log(user);
      $scope.user = user;
      modalInstance = $modal.open({
        templateUrl: "views/chat/user_card.html",
        scope: $scope
      });
      modalInstance.result.then((function(selectedItem) {}), function() {
        $scope.modalInstance = null;
      });
      return $scope.modalInstance = modalInstance;
    };
    $scope.chatRoom = function(user) {
      console.log(user);
      $scope.slide = 'slide-left';
      if ($scope.modalInstance != null) {
        $scope.modalInstance.close();
      }
      return Util.Go('chatRoom/' + user._id);
    };
    return $scope.sayHi = function(user) {
      if (user.status === '0') {
        console.log('sayhi');
        setTimeout(function() {
          return socket.emit("hi", {
            targetId: user._id
          }, 100000);
        });
      }
    };
  });

  angular.module('hiin').filter('convertMsg', function() {
    return function(activity) {
      if (activity.lastMsg.type === 'hi') {
        return 'Sent \'HI\'!';
      } else {
        return activity.lastMsg.content;
      }
    };
  });

  angular.module("hiin").directive("ngDisplayYou", function($window) {
    return {
      link: function(scope, element, attrs) {
        console.log(attrs.sender);
        if (attrs.sender === 'me') {
          return element.show();
        } else {
          return element.hide();
        }
      }
    };
  });

  angular.module("hiin").directive("ngDot", function($window) {
    return {
      link: function(scope, element, attrs) {
        console.log(attrs.read);
        if (attrs.read === true) {
          return element.hide();
        } else {
          return element.show();
        }
      }
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module("hiin").controller("chatCtrl", function($scope, $window, socket, Util, $stateParams, $ionicScrollDelegate) {
    var messageKey, messages, partnerId, thisEvent, w;
    console.log('chat');
    console.dir($stateParams);
    $scope.$on("$destroy", function(event) {
      socket.removeAllListeners();
    });
    partnerId = $stateParams.userId;
    thisEvent = window.localStorage['thisEvent'];
    messageKey = thisEvent + '_' + partnerId;
    messages = window.localStorage[messageKey] || [];
    if (messages.length > 0) {
      $scope.messages = JSON.parse(messages);
    } else {
      $scope.messages = messages;
    }
    socket.emit("getUserInfo", {
      targetId: $stateParams.userId
    });
    socket.on("getUserInfo", function(data) {
      console.log("chat,getUserInfo");
      $scope.opponent = data;
      $scope.partner = data.firstName;
      return $scope.roomName = "CHAT WITH " + data.firstName;
    });
    socket.on("message", function(data) {
      if (data.status < 0) {
        return;
      }
      if (data.from !== $stateParams.userId) {
        return;
      }
      $scope.messages.push({
        user: data.fromName,
        text: data.message,
        thumbnailUrl: data.thumbnailUrl,
        regTime: data.regTime,
        _id: data._id
      });
      window.localStorage[messageKey] = JSON.stringify($scope.messages);
      return $ionicScrollDelegate.scrollBottom();
    });
    $scope.sendMessage = function() {
      socket.emit("message", {
        targetId: $stateParams.userId,
        message: $scope.msg
      });
      $scope.messages.push({
        user: 'me',
        text: $scope.msg
      });
      $scope.msg = "";
      window.localStorage[messageKey] = JSON.stringify($scope.messages);
      return $ionicScrollDelegate.scrollBottom();
    };
    w = angular.element($window);
    $scope.getHeight = function() {
      return w.height();
    };
    $scope.$watch($scope.getHeight, function(newValue, oldValue) {
      $scope.windowHeight = newValue;
      $scope.style = function() {
        return {
          height: newValue + "px"
        };
      };
    });
    w.bind("resize", function() {
      $scope.$apply();
    });
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('EmailLoginCtrl', function(Util, $scope, $state) {
    $scope.signIn = function() {
      return Util.emailLogin($scope.userInfo).then(function(data) {
        return $state.go('enterEvent');
      }, function(status) {
        console.log(status);
        console.log('hi');
        if (status === '-2') {
          return $state.go('signUp');
        }
      });
    };
  });

  return;

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('eventCtrl', function($scope, $http, $window, Util, $location, $state) {
    $scope.slide = '';
    $scope.back = function() {
      $scope.slide = 'slide-right';
      return $window.history.back();
    };
    $scope.confirmCode = function() {
      return Util.ConfirmEvent($scope.formData).then(function(data) {
        return $state.go('list.userlists', null, {
          'reload': true
        });
      }, function(status) {
        return alert("invalid event code");
      });
    };
    return $scope.goToCreateEvent = function() {
      console.log('goto Create Event');
      return $state.go('createEventAttention');
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('CreateEventCtrl', function($scope, $window, $modal, Util, Host, $q, $state) {
    $scope.dateOptions = {
      minDate: new Date()
    };
    $scope.CreateEvent = function(eventInfo) {
      var deferred;
      deferred = $q.defer();
      Util.makeReq('post', 'event', eventInfo).success(function(data) {
        if (data.status >= '0') {
          console.log("$http.success");
          return deferred.resolve(data);
        } else {
          return deferred.reject(data);
        }
      }).error(function(error, status) {
        console.log("$http.error");
        return deferred.reject(status);
      });
      return deferred.promise;
    };
    $scope.pubish = function() {
      if ($scope.eventInfo !== null) {
        if (typeof $scope.eventInfo.startDate === 'undefined' || ($scope.eventInfo.startDate == null)) {
          alert('input start date');
          return;
        }
        $scope.eventInfo.startDate.setHours($scope.time.split(":")[0]);
        $scope.eventInfo.startDate.setMinutes($scope.time.split(":")[1]);
        $scope.eventInfo.endDate = new Date($scope.eventInfo.startDate.getTime());
        $scope.eventInfo.endDate.setMinutes($scope.eventInfo.endDate.getMinutes() + $scope.durationHour * 60);
        return $scope.CreateEvent($scope.eventInfo).then(function(data) {
          var confirmData;
          confirmData = {
            code: data.eventCode
          };
          $scope.eventCode = data.eventCode;
          Util.ConfirmEvent(confirmData).then(function(data) {
            var modalInstance;
            modalInstance = $modal.open({
              templateUrl: "views/event/passcode_dialog.html",
              scope: $scope
            });
            return modalInstance.result.then(function() {
              return console.log('불가');
            }, function() {
              return $state.go('list.userlists');
            }, function(status) {
              return alert("invalid event code");
            }, function(status) {
              return alert('err');
            });
          });
        });
      }
    };
    $scope.yes = function() {
      return $state.go('createEvent');
    };
    $scope.no = function() {
      return $window.history.back();
    };
    return $scope.backToList = function() {
      $scope.slide = 'slide-right';
      return $window.history.back();
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('eventInfoCtrl', function($scope, $rootScope, socket, $window, Util, $modal) {
    $scope.slide = '';
    socket.emit("currentEvent");
    $scope.$on("$destroy", function(event) {
      socket.removeAllListeners();
    });
    socket.on("currentEvent", function(data) {
      $scope.eventInfo = data;
      if (window.localStorage['myId'] === data.author) {
        $scope.isOwner = true;
        $scope.right_link = 'edit_link';
      }
    });
    $rootScope.back = function() {
      if ($scope.editMode === true) {
        $scope.editMode = false;
        socket.emit("currentEvent");
        return $scope.right_link = '';
      } else {
        $scope.slide = 'slide-right';
        return $window.history.back();
      }
    };
    return $scope.ToEditMode = function() {
      if ($scope.editMode === true) {
        return Util.makeReq('post', 'editEvent', $scope.eventInfo).success(function(data) {
          if (data.status >= '0') {
            console.log("$http.success");
            return socket.emit("currentEvent");
          } else {
            return console.log(data);
          }
        }).error(function(error, status) {
          console.log("$http.error");
          return alert('status');
        });
      } else {
        $scope.editMode = true;
        return $scope.right_link = 'save_link';
      }
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module("hiin").controller("grpChatCtrl", function($scope, $window, socket, Util, $location, $ionicScrollDelegate) {
    var messageKey, messages, myId, thisEvent;
    console.log('grpChat');
    $scope.$on("$destroy", function(event) {
      socket.removeAllListeners();
    });
    $scope.imagePath = Util.serverUrl() + "/";
    myId = window.localStorage['myId'];
    thisEvent = window.localStorage['thisEvent'];
    messageKey = thisEvent + '_groupMessage';
    $scope.roomName = "GROUP CHAT";
    messages = window.localStorage[messageKey] || [];
    if (messages.length > 0) {
      $scope.messages = JSON.parse(messages);
    } else {
      $scope.messages = messages;
    }
    socket.on("groupMessage", function(data) {
      var whosMessage;
      console.log("grp chat,groupMessage");
      whosMessage = "";
      if (myId === data._id) {
        whosMessage = 'me';
      } else {
        whosMessage = data.fromName;
      }
      $scope.messages.push({
        user: whosMessage,
        text: data.message,
        thumbnailUrl: data.thumbnailUrl,
        regTime: data.regTime,
        _id: data._id
      });
      socket.emit("read", {
        msgId: data.msgId
      });
      window.localStorage[messageKey] = JSON.stringify($scope.messages);
      $ionicScrollDelegate.scrollBottom();
    });
    return $scope.sendMessage = function() {
      socket.emit("groupMessage", {
        message: $scope.msg
      });
      return $scope.msg = "";
    };
  });

  angular.module("hiin").directive("ngChatBalloon", function($window) {
    return {
      link: function(scope, element, attrs) {
        console.log(attrs.user);
        if (attrs.user === 'me') {
          return element.addClass('chat-balloon-me');
        } else {
          return element.addClass('chat-balloon-you');
        }
      }
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('ListCtrl', function($rootScope, $scope, $window, Util, socket, $modal, $state, $location, $ionicNavBarDelegate) {
    socket.emit("currentEvent");
    socket.emit("myInfo");
    $scope.$on("$destroy", function(event) {
      socket.removeAllListeners();
    });
    socket.on("currentEvent", function(data) {
      console.log("list currentEvent");
      $scope.eventName = data.name;
      window.localStorage['thisEvent'] = data.code;
      socket.emit("currentEventUserList");
      console.log("socket emit current event user list");
      $ionicNavBarDelegate.showBackButton(false);
    });
    socket.on("myInfo", function(data) {
      console.log("list myInfo");
      console.log(data);
      window.localStorage['myId'] = data._id;
      $ionicNavBarDelegate.showBackButton(false);
    });
    socket.on("currentEventUserList", function(data) {
      console.log("list currentEventUserList");
      $scope.users = data;
      return $ionicNavBarDelegate.showBackButton(false);
    });
    socket.on("userListChange", function(data) {
      console.log('userListChange');
      console.log(data);
      return socket.emit("currentEventUserList");
    });
    $scope.chatRoom = function(user) {
      console.log(user);
      if ($scope.modalInstance != null) {
        $scope.modalInstance.close();
      }
      return $location.url('/list/userlists/' + user._id);
    };
    $scope.sayHi = function(user) {
      if (user.status === '0') {
        console.log('sayhi');
        setTimeout(function() {
          return socket.emit("hi", {
            targetId: user._id
          }, 100000);
        });
      }
    };
    socket.on("hi", function(data) {
      console.log("list hi");
      if (data.status === '0') {
        console.log('hi');
        return socket.emit("currentEventUserList");
      } else {
        return alert(data.fromName + " say hi");
      }
    });
    socket.on("pendingHi", function(data) {
      console.log("list pedinghi");
      if (data.status !== "0") {
        console.log({
          'error': data.status
        });
        return;
      }
      return socket.emit("currentEventUserList");
    });
    $scope.activity = function() {
      return $location.url('/list/activity');
    };
    $scope.groupChat = function() {
      return $location.url('/list/groupChat');
    };
    $scope.info = function() {
      return $location.url('/list/eventInfo');
    };
    $scope.imagePath = Util.serverUrl() + "/";
    return $scope.ShowProfile = function(user) {
      var modalInstance;
      console.log(user);
      $scope.user = user;
      modalInstance = $modal.open({
        templateUrl: "views/chat/user_card.html",
        scope: $scope
      });
      modalInstance.result.then((function(selectedItem) {}), function() {
        $scope.modalInstance = null;
      });
      return $scope.modalInstance = modalInstance;
    };
  });

  angular.module("hiin").directive("ngHiBtn", function($window) {
    return {
      link: function(scope, element, attrs) {
        console.log(attrs.histatus);
        if (attrs.histatus === '0') {
          console.log('btn status = hi');
          return element.addClass('btn-front');
        } else {
          console.log('btn Status = in');
          element.removeClass('btnHi');
          element.addClass('btn-back');
          return console.log(element);
        }
      }
    };
  });

  angular.module("hiin").directive("ngInBtn", function($window) {
    return {
      link: function(scope, element, attrs) {
        console.log(attrs.histatus);
        if (attrs.histatus === '0') {
          console.log('btn status = hi');
          return element.addClass('btn-back');
        } else {
          console.log('btn Status = in');
          element.removeClass('btnHi');
          element.addClass('btn-front');
          return console.log(element);
        }
      }
    };
  });

  angular.module("hiin").directive("ngFlipBtn", function($window) {
    return {
      link: function(scope, element, attrs) {
        console.log(attrs.histatus);
        if (attrs.histatus === '0') {
          return element.bind('click', function() {
            element.addClass('btn-flip');
            return console.log('addclass');
          });
        } else {
          return console.log('btn Status = in');
        }
      }
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('LoginCtrl', function($scope, $window, $location) {
    $scope.facebookLogin = function() {
      return alert('facebooklogin');
    };
    $scope.signUp = function() {
      return $location.url('/signUp');
    };
    return $scope.emailLogin = function() {
      return $location.url('/emailLogin');
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('MenuCtrl', function($scope, Util, $window, socket, $state) {
    $scope.TermAndPolish = function() {
      $scope.slide = 'slide-left';
      return $state.go('termAndPolish');
    };
    $scope.Report = function() {
      $scope.slide = 'slide-left';
      return $state.go('report');
    };
    $scope.backToList = function() {
      $scope.slide = 'slide-right';
      return $window.history.back();
    };
    return $scope.signOut = function() {
      socket.emit("disconnect");
      return Util.authReq('get', 'logout', '').success(function(data) {
        if (data.status === "0") {
          console.log('logout');
          window.localStorage.clearAll();
          return $state.go('/');
        }
      }).error(function(error, status) {
        return console.log("error");
      });
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('MenuEventCtrl', function($scope, Util, $http, socket, $log, $state) {
    $scope.$on("$destroy", function(event) {
      socket.removeAllListeners();
    });
    socket.emit("enteredEventList");
    socket.on("enteredEventList", function(data) {

      /*
      리스트 작성
      우선순위
      1. 현재 이벤트
      2. 내가 생성한 이벤트
      3. 이벤트
       */
      $scope.thisEvent = new Array();
      $scope.thisEvent.code = window.localStorage['thisEvent'];
      $scope.myId = new Array();
      $scope.myId.author = window.localStorage['myId'];
      return $scope.events = data;
    });
    $scope.myEvent = function(event) {
      return event.code !== $scope.thisEvent.code && event.author === $scope.myId.author;
    };
    $scope.pastEvent = function(event) {
      return event.code !== $scope.thisEvent.code && event.author !== $scope.myId.author;
    };
    $scope.GotoEvent = function(code) {
      var confirmData;
      confirmData = {
        code: code
      };
      return Util.ConfirmEvent(confirmData).then(function(data) {
        return $state.go('list.userlists');
      }, function(status) {
        return alert("invalid event code");
      });
    };
    return $scope.goToCreateEvent = function() {
      console.log('goto Create Event');
      return $state.go('createEventAttention');
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('ProfileCtrl', function($scope, Util, Host, socket, upload) {
    $scope.$on("$destroy", function(event) {
      socket.removeAllListeners();
    });
    $scope.imagePath = Util.serverUrl() + '/';
    $scope.gender2 = function(event) {
      return event.code !== $scope.thisEvent.code && event.author !== $scope.myId.author;
    };
    $scope.isNotEdit = true;
    $scope.btn_edit_or_confirm = 'edit';
    socket.emit("myInfo");
    socket.on("myInfo", function(data) {
      console.log("profile myInfo");
      return $scope.userInfo = data;
    });
    return $scope.editProfile = function() {
      if ($scope.isNotEdit === true) {
        $scope.isNotEdit = false;
        return $scope.btn_edit_or_confirm = 'confirm';
      } else {
        return Util.authReq('post', 'editUser', $scope.userInfo).success(function(data) {
          return console.log(data);
        }).error(function(data, status) {
          return console.log(data);
        });
      }
    };
  });

  angular.module("hiin").directive("ngGender", function($window) {
    return {
      link: function(scope, element, attrs) {
        console.log(attrs.ngGender);
        console.log('attrs');
        console.dir(attrs);
        console.log(attrs.gender);
        if (attrs.gender === '0') {
          console.log('gender 0');
          return scope.gender = 'women';
        } else if (attrs.gender === '1') {
          console.log('gender 1');
          return scope.gender = 'men';
        }
      }
    };
  });

}).call(this);

(function() {
  "use strict";
  angular.module("hiin").controller("SignUpCtrl", function($sce, $q, $http, $scope, $window, Util, Host, socket, $state) {
    $scope.photoUrl = 'images/no_image.jpg';
    $scope.imageUploadUrl = "" + (Host.getAPIHost()) + ":" + (Host.getAPIPort()) + "/profileImage";
    $scope.crop_mode = false;
    $scope.CropMode = function() {
      if ($scope.crop_mode === false) {
        $scope.crop_mode = true;
        return $scope.cropUrl = $sce.trustAsResourceUrl($scope.photoUrl);
      } else {
        return $scope.crop_mode = false;
      }
    };
    $scope.RunCrop = function() {
      var data, org_image, style;
      style = angular.element('#img_crop').find('.jcrop-holder').children()[0].style;
      org_image = document.getElementById('img_profile');
      data = {
        url: $scope.userInfo.photoUrl,
        top: style.top,
        left: style.left,
        height: style.height,
        width: style.width,
        originalHeight: org_image.naturalHeight,
        originalWidth: org_image.naturalWidth
      };
      return Util.makeReq('post', 'cropImage', data).success(function(data) {
        userInfo.photoUrl = data.photoUrl;
        userInfo.thumbnailUrl = data.thumbnailUrl;
        $scope.photoUrl = Util.serverUrl() + "/" + data.photoUrl;
        return $scope.thumbnailUrl = Util.serverUrl() + "/" + data.thumbnailUrl;
      }).error(function(error, status) {
        return console.log(error);
      });
    };
    $scope.onSuccess = function(response) {
      userInfo.photoUrl = response.data.photoUrl;
      userInfo.thumbnailUrl = response.data.thumbnailUrl;
      $scope.photoUrl = Util.serverUrl() + "/" + response.data.photoUrl;
      $scope.thumbnailUrl = Util.serverUrl() + "/" + response.data.thumbnailUrl;
      return $scope.userInfo = userInfo;
    };
    $scope.makeId = function(userInfo) {
      var deferred;
      console.log(userInfo);
      deferred = $q.defer();
      Util.makeReq('post', 'user', userInfo).success(function(data) {
        if (data.status < "0") {
          deferred.reject(data);
        }
        return deferred.resolve(data);
      }).error(function(data, status) {
        console.log(data);
        return deferred.reject(status);
      });
      return deferred.promise;
    };
    $scope.signUp = function() {
      $scope.makeId($scope.userInfo).then(function(data) {
        return $scope.signIn();
      }, function(status) {
        return alert('err');
      });
    };
    $scope.signIn = function() {
      Util.emailLogin($scope.userInfo).then(function(data) {
        return $state.go('enterEvent');
      }, function(status) {
        return alert(status);
      });
    };
    $scope.open = function($event) {
      $event.preventDefault();
      $event.stopPropagation();
      $scope.opened = true;
    };
    return $scope.dateOptions = {
      'year-format': "'yy'",
      'starting-day': 1
    };
  });

  angular.module("hiin").directive("imgCropped", function() {
    return {
      restrict: "E",
      replace: true,
      scope: {
        src: "@",
        selected: "&"
      },
      link: function(scope, element, attr) {
        var clear, myImg;
        myImg = void 0;
        clear = function() {
          if (myImg) {
            myImg.next().remove();
            myImg.remove();
            myImg = undefined;
          }
        };
        scope.$watch("src", function(nv) {
          clear();
          if (nv) {
            element.after("<img />");
            myImg = element.next();
            myImg.attr("src", nv);
            $(myImg).Jcrop({
              trackDocument: true,
              onSelect: function(x) {
                scope.$apply(function() {
                  scope.selected({
                    cords: x
                  });
                });
              },
              aspectRatio: 1
            });
          }
        });
        scope.$on("$destroy", clear);
      }
    };
  });

}).call(this);

(function() {
  "use strict";
  angular.module("hiin.controllers", []).controller("IntroCtrl", function($scope, $state, $ionicSlideBoxDelegate) {
    $scope.startApp = function() {
      $state.go("main");
    };
    $scope.next = function() {
      $ionicSlideBoxDelegate.next();
    };
    $scope.previous = function() {
      $ionicSlideBoxDelegate.previous();
    };
    $scope.slideChanged = function(index) {
      $scope.slideIndex = index;
    };
  }).controller("MainCtrl", function($scope, $state) {
    console.log("MainCtrl");
    $scope.toIntro = function() {
      $state.go("intro");
    };
  });

}).call(this);
