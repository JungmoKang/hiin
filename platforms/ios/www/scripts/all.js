'use strict';

// AngularJS 에서 module을 정의할 때 뒤에 dependecy list를 주게 되면 새로운 module을 정의하겠다는 소리고
// 단순히 angular.module('services') 하게 되면 기존에 만들어진 module을 refer하겠다는 의미임.

// services 라는 모듈 선언
angular.module('services', [])
  // API_PORT를 상수로 정의. API_PORT는 나중에 dependency injection에서 쓰일 수 있음.
  .constant('API_PORT', 3000)
  // API_HOST를 상수로 정의.
//  .constant('API_HOST', "http://192.168.0.26");
  //.constant('API_HOST', "http://ec2-54-86-232-223.compute-1.amazonaws.com");
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
  angular.module('services').factory('Util', function($q, $http, $window, $location, $document, Host, Token, $ionicModal, $timeout) {
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
      },
      ShowModal: function(scope, html_file) {
        console.log('show modal');
        return $ionicModal.fromTemplateUrl("views/modal/" + html_file + ".html", (function($ionicModal) {
          scope.modal = $ionicModal;
          scope.modal.show();
        }), {
          scope: scope,
          animation: "slide-in-up"
        });
      },
      resSocket: function(options) {
        var deferred, recieved, waiting;
        recieved = false;
        deferred = $q.defer();
        socket.on(options.on, function(data) {
          recieved = true;
          $timeout((function() {
            options.onCallback(data);
            $timeout.cancel(waiting);
            if (options.loadingstop) {
              return options.loadingstop();
            }
          }), options.defaultDuration);
        });
        if (options.loadingStart) {
          options.loadingStart();
        }
        if (options.emit) {
          socket.emit(options.emit, options.emit);
        } else {
          socket.emit(options.emit);
        }
        waiting = $timeout((function() {
          if (recieved === true) {
            deferred.resolve('success');
          } else {
            deferred.reject('fail');
          }
        }), options.duration);
        return deferred.promise;
      }
    };
  });

}).call(this);

(function() {
  angular.module('services').factory('Migration', function() {
    return {
      truncate: function(db) {
        console.log("migration truncate!");
        return db.transaction(function(tx) {
          var table_name;
          table_name = "message";
          return tx.executeSql("DELETE FROM " + table_name);
        }, function(error) {
          return console.error("Transaction error : " + error.message);
        });
      },
      apply: function(db) {
        console.log("webDb.apply");
        return db.transaction(function(tx) {
          var table_name;
          table_name = "chatMessages";
          tx.executeSql("CREATE TABLE IF NOT EXISTS " + table_name + " (id unique, message, from_id, from_name, thumnailUrl,regTime,eventCoide,msgId)");
          return console.log("transaction function finished");
        }, function(error) {
          return console.error("Transaction error = " + error.message);
        });
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
    }).state("/signin", {
      url: "/signin",
      templateUrl: "views/login/signin.html",
      controller: "SignInCtrl"
    }).state("/organizerLogin", {
      url: "/organizerLogin",
      templateUrl: "views/login/organizerLogin.html",
      controller: "OrganizerLoginCtrl"
    }).state("/resetPassword", {
      url: "/resetPassword",
      templateUrl: "views/login/reset_password.html",
      controller: "OrganizerLoginCtrl"
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
    }).state("list.organizerSignUp", {
      url: "/organizerSignUp",
      views: {
        menuContent: {
          templateUrl: "views/login/organizerSignUp.html",
          controller: "OrganizerLoginCtrl"
        }
      }
    }).state("list.organizerLogin", {
      url: "/organizerLogin",
      views: {
        menuContent: {
          templateUrl: "views/login/organizerLoginFromEventPage.html",
          controller: "OrganizerLoginCtrl"
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

(function() {
  'use strict';
  angular.module('hiin').controller('ActivityCtrl', function($scope, $rootScope, $location, $window, Util, socket, $modal) {
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
    $scope.showRank = function() {
      return $scope.modalInstance = $modal.open({
        templateUrl: "views/list/rank_modal.html",
        scope: $scope
      });
    };
    $scope.ok = function() {
      return $scope.modalInstance.close();
    };
    $scope.ShowProfile = function(user) {
      var modalInstance;
      console.log(user);
      $scope.user = user;
      modalInstance = $modal.open({
        templateUrl: "views/dialog/user_card.html",
        scope: $scope
      });
      modalInstance.result.then((function(selectedItem) {}), function() {
        $scope.modalInstance = null;
      });
      return $scope.modalInstance = modalInstance;
    };
    $scope.chatRoom = function(user) {
      console.log(user);
      if ($scope.modalInstance != null) {
        $scope.modalInstance.close();
      }
      return $location.url('/list/userlists/' + user._id);
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

  angular.module('hiin').filter('fromNow', function() {
    return function(time) {
      return moment(time).fromNow();
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
  angular.module("hiin").controller("chatCtrl", function($scope, $window, socket, Util, $stateParams, $ionicScrollDelegate, $timeout) {
    var isIOS, messageKey, partnerId, thisEvent;
    console.log('chat');
    console.dir($stateParams);
    partnerId = $stateParams.userId;
    if ($window.localStorage != null) {
      thisEvent = $window.localStorage.getItem("thisEvent");
      $scope.myId = $window.localStorage.getItem('myId');
    }
    messageKey = thisEvent + '_' + partnerId;
    if ($window.localStorage.getItem(messageKey)) {
      $scope.messages = JSON.parse($window.localStorage.getItem(messageKey));
    } else {
      $scope.messages = [];
    }
    if ($scope.messages.length > 0) {
      console.log('----unread----');
      console.log('len:' + $scope.messages.length);
      socket.emit('loadMsgs', {
        code: thisEvent,
        partner: partnerId,
        type: "personal",
        range: "unread",
        lastMsgTime: $scope.messages[$scope.messages.length - 1].created_at
      });
    } else {
      console.log('---call all---');
      socket.emit('loadMsgs', {
        code: thisEvent,
        partner: partnerId,
        type: "personal",
        range: "all"
      });
    }
    $scope.pullLoadMsg = function() {
      console.log('---pull load msg---');
      return socket.emit('loadMsgs', {
        code: thisEvent,
        partner: partnerId,
        type: "personal",
        range: "pastThirty",
        firstMsgTime: $scope.messages[0].created_at
      });
    };
    socket.on('loadMsgs', function(data) {
      var tempor;
      if (data.message) {
        data.message.forEach(function(item) {
          if (item.sender === $scope.myId) {
            item.sender_name = 'me';
          }
        });
      }
      if (data.type === 'personal' && data.range === 'all') {
        console.log('---all---');
        $scope.messages = data.message;
      } else if (data.type === 'personal' && data.range === 'unread') {
        console.log('---unread----');
        console.log(data);
        tempor = $scope.messages.concat(data.message);
        console.log(tempor);
        console.log('tmper len:' + tempor.length);
        $scope.messages = tempor;
      } else if (data.type === 'personal' && data.range === 'pastThirty') {
        console.log('---else---');
        tempor = data.message.reverse().concat($scope.messages);
        console.log(tempor);
        console.log('tmper len:' + tempor.length);
        $scope.messages = tempor;
        $scope.$broadcast('scroll.refreshComplete');
      }
      return $window.localStorage.setItem(messageKey, JSON.stringify($scope.messages));
    });
    socket.emit("getUserInfo", {
      targetId: $stateParams.userId
    });
    $scope.data = {};
    $scope.data.message = "";
    window.addEventListener("native.keyboardshow", function(e) {
      console.log("Keyboard height is: " + e.keyboardHeight);
      if ($scope.input_mode !== true) {
        cordova.plugins.Keyboard.close();
        $scope.input_mode = true;
      }
    });
    window.addEventListener("native.keyboardhide", function(e) {
      console.log("Keyboard close");
    });
    ionic.DomUtil.ready(function() {
      if (window.cordova) {
        return cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      }
    });
    $scope.$on("$destroy", function(event) {
      var len, temp;
      if (window.cordova) {
        cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(false) && cordova.plugins.Keyboard.close();
      }
      socket.removeAllListeners();
      temp = $scope.messages;
      len = temp.length;
      console.log('mlen:' + len);
      if (len > 30) {
        window.localStorage[messageKey] = JSON.stringify(temp.slice(len - 30, temp.length));
      }
    });
    isIOS = ionic.Platform.isWebView() && ionic.Platform.isIOS();
    socket.on("getUserInfo", function(data) {
      console.log("chat,getUserInfo");
      $scope.opponent = data;
      $scope.partner = data.firstName;
      return $scope.roomName = "CHAT WITH " + data.firstName;
    });
    socket.on("message", function(data) {
      console.log('ms');
      console.log(data);
      if (data.status < 0) {
        return;
      }
      if (data.sender !== $stateParams.userId) {
        return;
      }
      $scope.messages.push(data);
      $window.localStorage.setItem(messageKey, JSON.stringify($scope.messages));
      return $ionicScrollDelegate.scrollBottom();
    });
    $scope.sendMessage = function() {
      var time;
      if ($scope.data.message === "") {
        return;
      }
      time = new Date();
      socket.emit("message", {
        created_at: time,
        targetId: $stateParams.userId,
        message: $scope.data.message
      });
      $scope.messages.push({
        sender_name: 'me',
        content: $scope.data.message,
        created_at: time
      });
      $scope.data.message = "";
      $window.localStorage.setItem(messageKey, JSON.stringify($scope.messages));
      return $ionicScrollDelegate.scrollBottom();
    };
    return;
    $scope.inputUp = function() {
      console.log('inputUp');
      if (isIOS) {
        $scope.data.keyboardHeight = 216;
      }
      $timeout((function() {
        $ionicScrollDelegate.scrollBottom(true);
      }), 300);
    };
    $scope.inputDown = function() {
      console.log('inputDown');
      if (isIOS) {
        $scope.data.keyboardHeight = 0;
      }
      $ionicScrollDelegate.resize();
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('EmailLoginCtrl', function(Util, $scope, $state) {
    $scope.signIn = function() {
      return Util.emailLogin($scope.userInfo).then(function(data) {
        return $state.go('list.events');
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
  "use strict";
  angular.module("hiin").controller("SignUpCtrl", function($modal, $sce, $q, $http, $scope, $window, Util, Host, socket, $state, $timeout) {
    $scope.photoUrl = 'images/no_image.jpg';
    $scope.imageUploadUrl = "" + (Host.getAPIHost()) + ":" + (Host.getAPIPort()) + "/profileImage";
    $scope.onSuccess = function(response) {
      var userInfo;
      console.log("onSucess");
      console.log(response);
      if ($scope.userInfo != null) {
        userInfo = $scope.userInfo;
      } else {
        userInfo = {};
      }
      userInfo.photoUrl = response.data.photoUrl;
      userInfo.thumbnailUrl = response.data.thumbnailUrl;
      $scope.photoUrl = Util.serverUrl() + "/" + response.data.photoUrl;
      $scope.thumbnailUrl = Util.serverUrl() + "/" + response.data.thumbnailUrl;
      $scope.userInfo = userInfo;
      angular.element('img.image_upload_btn').attr("src", $scope.thumbnailUrl);
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
    $scope.signUp = function(isValid) {
      console.log(isValid);
      if (isValid === true) {
        $scope.makeId($scope.userInfo).then(function(data) {
          return $scope.signIn();
        }, function(status) {
          return alert('err');
        });
      } else {
        return $scope.showAlert();
      }
    };
    $scope.signIn = function() {
      Util.emailLogin($scope.userInfo).then(function(data) {
        return $state.go('list.events');
      }, function(status) {
        return alert(status);
      });
    };
    $scope.open = function($event) {
      $event.preventDefault();
      $event.stopPropagation();
      $scope.opened = true;
    };
    $scope.dateOptions = {
      'year-format': "'yy'",
      'starting-day': 1
    };
    return $scope.showAlert = function() {
      var modalInstance;
      return modalInstance = $modal.open({
        templateUrl: "views/login/alert.html",
        scope: $scope
      });
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('CreateEventCtrl', function($scope, $window, $modal, Util, Host, $q, $state) {
    $scope.sDate = {
      minDate: new Date(),
      onSelect: function(dateText, inst) {
        $scope.eDate.minDate = new Date(dateText);
        $scope.eventInfo.endDate = $scope.eventInfo.startDate;
        return console.log(dateText);
      }
    };
    $scope.eDate = {
      minDate: new Date()
    };
    $scope.eventInfo = {};
    $scope.startTime = "00:00";
    $scope.endTime = "00:00";
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
    return $scope.pubish = function() {
      if ($scope.eventInfo !== null) {
        if (typeof $scope.eventInfo.startDate === 'undefined' || ($scope.eventInfo.startDate == null)) {
          alert('input start date');
          return;
        }
        $scope.eventInfo.startDate.setHours($scope.startTime.split(":")[0]);
        $scope.eventInfo.startDate.setMinutes($scope.startTime.split(":")[1]);
        $scope.eventInfo.endDate.setHours($scope.endTime.split(":")[0]);
        $scope.eventInfo.endDate.setMinutes($scope.endTime.split(":")[1]);
        $scope.CreateEvent($scope.eventInfo).then(function(data) {
          var modalInstance;
          console.log(data);
          $scope.eventCode = data.eventCode;
          modalInstance = $modal.open({
            templateUrl: "views/event/passcode_dialog.html",
            scope: $scope
          });
          return modalInstance.result.then(function() {
            return console.log('불가');
          }, function() {
            return $state.go('list.userlists');
          });
        }, function(status) {
          return alert('err');
        });
      }
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
      if ($window.localStorage.getItem('myId' === data.author)) {
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
  angular.module("hiin").controller("grpChatCtrl", function($scope, $window, socket, Util, $location, $ionicScrollDelegate, $timeout) {
    var isIOS, messageKey, thisEvent;
    console.log('grpChat');
    $scope.input_mode = false;
    $scope.imagePath = Util.serverUrl() + "/";
    if ($window.localStorage != null) {
      thisEvent = $window.localStorage.getItem("thisEvent");
      $scope.myId = $window.localStorage.getItem('myId');
    }
    messageKey = thisEvent + '_groupMessage';
    $scope.roomName = "GROUP CHAT";
    if ($window.localStorage.getItem(messageKey)) {
      $scope.messages = JSON.parse($window.localStorage.getItem(messageKey));
    } else {
      $scope.messages = [];
    }
    $scope.data = {};
    $scope.data.message = "";
    $scope.amIOwner = false;
    if (window.localStorage['eventOwner'] === $scope.myId) {
      $scope.amIOwner = true;
      $scope.regular_msg_flg = false;
    }
    window.addEventListener("native.keyboardshow", function(e) {
      console.log("Keyboard height is: " + e.keyboardHeight);
      if ($scope.input_mode !== true) {
        cordova.plugins.Keyboard.close();
      }
    });
    window.addEventListener("native.keyboardhide", function(e) {
      console.log("Keyboard close");
      $scope.input_mode = true;
    });
    ionic.DomUtil.ready(function() {
      console.log('ready');
      if (window.cordova) {
        return cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      }
    });
    $scope.$on("$destroy", function(event) {
      if (window.cordova) {
        cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(false) && cordova.plugins.Keyboard.close();
      }
      socket.removeAllListeners();
    });
    isIOS = ionic.Platform.isWebView() && ionic.Platform.isIOS();
    socket.on("groupMessage", function(data) {
      console.log("grp chat,groupMessage");
      if ($scope.myId === data.sender) {
        data.sender_name = 'me';
      }
      $scope.messages.push(data);
      $window.localStorage.setItem(messageKey, JSON.stringify($scope.messages));
      $ionicScrollDelegate.scrollBottom();
    });
    $scope.sendMessage = function() {
      var time;
      time = new Date();
      if ($scope.data.message === "") {
        return;
      }
      if ($scope.regular_msg_flg === true) {
        socket.emit("groupMessage", {
          created_at: time,
          message: $scope.data.message
        });
      } else {
        socket.emit("notice", {
          created_at: time,
          message: $scope.data.message
        });
      }
      return $scope.data.message = "";
    };
    $scope.inputUp = function() {
      console.log('inputUp');
      window.scroll(0, 0);
      if (isIOS) {
        $scope.data.keyboardHeight = 216;
      }
      $timeout((function() {
        $ionicScrollDelegate.scrollBottom(true);
      }), 300);
    };
    $scope.inputDown = function() {
      console.log('inputDown');
      if (isIOS) {
        $scope.data.keyboardHeight = 0;
      }
      $ionicScrollDelegate.resize();
    };
    return $scope.toggleOwnerMsg = function() {
      $scope.regular_msg_flg = !$scope.regular_msg_flg;
      if ($scope.regular_msg_flg === true) {
        $scope.popupMessage = "Send as a regular chat message";
      } else {
        $scope.popupMessage = "Send as a notice to the group";
      }
      $scope.showingMsg = true;
      if ($scope.timer != null) {
        $timeout.cancel($scope.timer);
      }
      return $scope.timer = $timeout((function() {
        $scope.showingMsg = false;
      }), 2000);
    };
  });

  angular.module("hiin").directive("ngChatInput", function($timeout) {
    return {
      restrict: "A",
      scope: {
        returnClose: "=",
        onReturn: "&",
        onFocus: "&",
        onBlur: "&"
      },
      link: function(scope, element, attr) {
        element.bind("focus", function(e) {
          console.log('focusss');
          if (scope.onFocus) {
            window.scroll(0, 0);
            $timeout(function() {
              scope.onFocus();
            });
          }
        });
        element.bind("blur", function(e) {
          if (scope.onBlur) {
            $timeout(function() {
              scope.onBlur();
            });
          }
        });
        element.bind("keydown", function(e) {
          console.log(e);
          if (e.which === 13) {
            console.log('entered');
            if (scope.returnClose) {
              element[0].blur();
            }
            if (scope.onReturn) {
              $timeout(function() {
                scope.onReturn();
              });
            }
          }
        });
      }
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
  angular.module('hiin').controller('ListCtrl', function($route, $rootScope, $scope, $window, Util, socket, $modal, $state, $location, $ionicNavBarDelegate, $timeout) {
    $rootScope.selectedItem = 2;
    ionic.DomUtil.ready(function() {
      return $ionicNavBarDelegate.showBackButton(false);
    });
    socket.emit("currentEvent");
    socket.emit("myInfo");
    $scope.users = [];
    $scope.$on("$destroy", function(event) {
      socket.removeAllListeners();
    });
    socket.on("currentEvent", function(data) {
      console.log("list currentEvent");
      $scope.eventName = data.name;
      $window.localStorage.setItem('thisEvent', data.code);
      $window.localStorage.setItem('eventOwner', data.author);
      socket.emit("currentEventUserList");
      console.log("socket emit current event user list");
    });
    socket.on("myInfo", function(data) {
      console.log("list myInfo");
      console.log(data);
      $window.localStorage.setItem('myId', data._id);
      $ionicNavBarDelegate.showBackButton(false);
    });
    socket.on("currentEventUserList", function(data) {
      console.log("list currentEventUserList");
      $scope.users = data;
      console.log(data);
      return $ionicNavBarDelegate.showBackButton(false);
    });
    socket.on("userListChange", function(data) {
      console.log('userListChange');
      console.log(data);
      return socket.emit("currentEventUserList");
    });
    $scope.chatRoom = function(user) {
      if ($scope.modalInstance != null) {
        $scope.modalInstance.close();
      }
      return $location.url('/list/userlists/' + user._id);
    };
    $scope.sayHi = function(user) {
      if (user.status === '0' || user.status === '2') {
        console.log('sayhi');
        setTimeout(function() {
          return socket.emit("hi", {
            targetId: user._id
          }, 100000);
        });
      }
    };
    socket.on("hi", function(data) {
      var modalInstance;
      $scope.sendHi = data.fromName;
      modalInstance = $modal.open({
        templateUrl: "views/list/hi_modal.html",
        scope: $scope
      });
      modalInstance.result.then((function(selectedItem) {}), function() {
        $scope.modalInstance = null;
      });
      return $scope.modalInstance = modalInstance;
    });
    socket.on("hiMe", function(data) {
      return socket.emit("currentEventUserList");
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
    $scope.ShowProfile = function(user) {
      var modalInstance;
      console.log(user);
      $scope.user = user;
      modalInstance = $modal.open({
        templateUrl: "views/dialog/user_card.html",
        scope: $scope
      });
      modalInstance.result.then((function(selectedItem) {
        $scope.modalInstance = null;
      }), function() {
        $scope.modalInstance = null;
      });
      return $scope.modalInstance = modalInstance;
    };
    $scope.ShowPrivacyFreeDialog = function() {
      var modalInstance;
      if ($window.localStorage.getItem('flg_show_privacy_dialog')) {
        return;
      }
      modalInstance = $modal.open({
        templateUrl: "views/dialog/privacy_free.html",
        scope: $scope
      });
      modalInstance.result.then((function(selectedItem) {
        $scope.modalInstance = null;
      }), function() {
        $scope.modalInstance = null;
      });
      $scope.modalInstance = modalInstance;
      return $window.localStorage.setItem('flg_show_privacy_dialog', true);
    };
    $scope.CloseDialog = function() {
      return $scope.modalInstance.close();
    };
    return $scope.ShowPrivacyFreeDialog();
  });

  angular.module("hiin").directive("ngHiBtn", function($window) {
    return {
      link: function(scope, element, attrs) {
        console.log(attrs.histatus);
        if (attrs.histatus === '0') {
          console.log('btn status = hi');
          return element.addClass('btn-front');
        } else if (attrs.histatus === '2') {
          element.addClass('btn-Hi');
          return element.addClass('btn-front');
        } else {
          console.log('btn Status = in');
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
        if (attrs.histatus === '0' || attrs.histatus === '2') {
          console.log('btn status = hi');
          return element.addClass('btn-back');
        } else {
          console.log('btn Status = in');
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
        } else if (attrs.histatus === '2') {
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
    if ($window.localStorage != null) {
      $window.localStorage.clear();
    }
    $scope.facebookLogin = function() {
      return alert('facebooklogin');
    };
    $scope.signin = function() {
      return $location.url('/signin');
    };
    return $scope.organizerLogin = function() {
      return $location.url('/organizerLogin');
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('MenuCtrl', function($rootScope, $scope, Util, $window, socket, $state, $modal) {
    $rootScope.selectedItem = 4;
    $scope.TermAndPolish = function() {
      $scope.slide = 'slide-left';
      return $state.go('termAndPolish');
    };
    $scope.Report = function() {
      $scope.slide = 'slide-left';
      return $state.go('report');
    };
    $scope.signOut = function() {
      var modalInstance;
      modalInstance = $modal.open({
        templateUrl: "views/dialog/logout_notice.html",
        scope: $scope
      });
      modalInstance.result.then((function(selectedItem) {
        $scope.modalInstance = null;
      }), function() {
        return $scope.modalInstance = null;
      });
      return $scope.modalInstance = modalInstance;
    };
    $scope.okay = function() {
      console.log('ok');
      $scope.modalInstance.close();
      socket.emit("disconnect");
      return Util.authReq('get', 'logout', '').success(function(data) {
        if (data.status === "0") {
          console.log('logout');
          if ($window.localStorage != null) {
            $window.localStorage.clear();
          }
          return $state.go('/');
        }
      }).error(function(error, status) {
        return console.log("error");
      });
    };
    return $scope.cancel = function() {
      console.log('cancel');
      return $scope.modalInstance.close();
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('MenuEventCtrl', function($rootScope, $scope, Util, $http, socket, $log, $state, $ionicScrollDelegate, $ionicNavBarDelegate, $timeout, $ionicModal, $window) {
    $rootScope.selectedItem = 3;
    ionic.DomUtil.ready(function() {
      return $ionicNavBarDelegate.showBackButton(false);
    });
    if (window.localStorage['thisEvent'] != null) {
      $scope.enteredEventsOrOwner = true;
    }
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
      $scope.thisEvent.code = $window.localStorage.getItem('thisEvent');
      $scope.myId = new Array();
      $scope.myId.author = $window.localStorage.getItem('myId');
      return $scope.events = data;
    });
    $scope.$on("$destroy", function(event) {
      socket.removeAllListeners();
      if ($scope.modal != null) {
        $scope.modal.hide();
      }
    });
    $scope.confirmCode = function() {
      var promise;
      promise = Util.ConfirmEvent($scope.formData);
      $scope.message = 'loaded';
      Util.ShowModal($scope, 'create_or_loaded_event');
      return $timeout((function() {
        return promise.then(function(data) {
          $scope.modal.hide();
          return $state.go('list.userlists');
        }, function(status) {
          console.log('error');
          $scope.modal.hide();
          return Util.ShowModal($scope, 'no_event');
        });
      }), 1000000);
    };
    $scope.CreateEvent = function() {
      return $state.go('list.createEvent');
    };
    $scope.yes = function() {
      $scope.modal.hide();
      return $state.go('list.organizerSignUp');
    };
    $scope.no = function() {
      return $scope.modal.hide();
    };
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
        console.log('error');
        return Util.ShowModal($scope, 'no_event');
      });
    };
    return $scope.back = function() {
      return $scope.modal.hide();
    };
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('ProfileCtrl', function($rootScope, $scope, Util, Host, socket, upload) {
    $rootScope.selectedItem = 1;
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
  'use strict';
  angular.module('hiin').controller('OrganizerLoginCtrl', function(Util, $scope, $state, $window) {
    $scope.Login = function() {
      return Util.emailLogin($scope.userInfo).then(function(data) {
        return $state.go('list.events');
      }, function(status) {
        console.log(status);
        console.log('error');
        return $scope.showErrMsg = true;
      });
    };
    $scope.back = function() {
      return $window.history.back();
    };
    $scope.GotoResetPassword = function() {
      return $state.go('/resetPassword');
    };
    $scope.ResetPassword = function() {};
    $scope.CloseErroMsg = function() {
      return $scope.showErrMsg = false;
    };
    $scope.CreateAndSignIn = function() {};
    $scope.organizerLogin = function() {
      return $state.go('list.organizerLogin');
    };
    $scope.SignIn = function() {};
  });

  return;

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('SignInCtrl', function($modal, $sce, $q, $http, $scope, $window, Util, Host, socket, $state, $timeout) {
    $scope.userInfo = {};
    $scope.userInfo.gender = 1;
    $scope.photoUrl = 'images/no_image.jpg';
    $scope.imageUploadUrl = "" + (Host.getAPIHost()) + ":" + (Host.getAPIPort()) + "/profileImage";
    $scope.ToggleGender = function(gender) {
      return $scope.userInfo.gender = gender;
    };
    $scope.back = function() {
      return $window.history.back();
    };
    $scope.onSuccess = function(response) {
      var userInfo;
      console.log("onSucess");
      console.log(response);
      if ($scope.userInfo != null) {
        userInfo = $scope.userInfo;
      } else {
        userInfo = {};
        userInfo.gender = 1;
      }
      userInfo.photoUrl = response.data.photoUrl;
      userInfo.thumbnailUrl = response.data.thumbnailUrl;
      $scope.photoUrl = Util.serverUrl() + "/" + response.data.photoUrl;
      $scope.thumbnailUrl = Util.serverUrl() + "/" + response.data.thumbnailUrl;
      $scope.userInfo = userInfo;
      angular.element('img.image_upload_btn').attr("src", $scope.thumbnailUrl);
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
    $scope.SignUp = function(isValid) {
      console.log(isValid);
      if (isValid === true) {
        $scope.makeId($scope.userInfo).then(function(data) {
          return $scope.signIn();
        }, function(status) {
          return alert('err');
        });
      } else {
        return $scope.showAlert();
      }
    };
    $scope.signIn = function() {
      Util.emailLogin($scope.userInfo).then(function(data) {
        return $state.go('list.events');
      }, function(status) {
        return alert(status);
      });
    };
    $scope.open = function($event) {
      $event.preventDefault();
      $event.stopPropagation();
      $scope.opened = true;
    };
    return $scope.showAlert = function() {
      var modalInstance;
      return modalInstance = $modal.open({
        templateUrl: "views/login/alert.html",
        scope: $scope
      });
    };
  });

}).call(this);

(function() {
  "use strict";
  angular.module("hiin").controller("SignUpCtrl", function($modal, $sce, $q, $http, $scope, $window, Util, Host, socket, $state, $timeout) {
    $scope.photoUrl = 'images/no_image.jpg';
    $scope.imageUploadUrl = "" + (Host.getAPIHost()) + ":" + (Host.getAPIPort()) + "/profileImage";
    $scope.onSuccess = function(response) {
      var userInfo;
      console.log("onSucess");
      console.log(response);
      if ($scope.userInfo != null) {
        userInfo = $scope.userInfo;
      } else {
        userInfo = {};
      }
      userInfo.photoUrl = response.data.photoUrl;
      userInfo.thumbnailUrl = response.data.thumbnailUrl;
      $scope.photoUrl = Util.serverUrl() + "/" + response.data.photoUrl;
      $scope.thumbnailUrl = Util.serverUrl() + "/" + response.data.thumbnailUrl;
      $scope.userInfo = userInfo;
      angular.element('img.image_upload_btn').attr("src", $scope.thumbnailUrl);
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
    $scope.signUp = function(isValid) {
      console.log(isValid);
      if (isValid === true) {
        $scope.makeId($scope.userInfo).then(function(data) {
          return $scope.signIn();
        }, function(status) {
          return alert('err');
        });
      } else {
        return $scope.showAlert();
      }
    };
    $scope.signIn = function() {
      if ($window.localStorage != null) {
        $window.localStorage.clear();
      }
      Util.emailLogin($scope.userInfo).then(function(data) {
        return $state.go('list.events');
      }, function(status) {
        return alert(status);
      });
    };
    $scope.open = function($event) {
      $event.preventDefault();
      $event.stopPropagation();
      $scope.opened = true;
    };
    $scope.dateOptions = {
      'year-format': "'yy'",
      'starting-day': 1
    };
    return $scope.showAlert = function() {
      var modalInstance;
      return modalInstance = $modal.open({
        templateUrl: "views/login/alert.html",
        scope: $scope
      });
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
