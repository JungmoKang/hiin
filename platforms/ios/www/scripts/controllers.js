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
    var isIOS, messageKey, messages, partnerId, thisEvent;
    console.log('chat');
    console.dir($stateParams);
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
      if (window.cordova) {
        cordova.plugins && cordova.plugins.Keyboard && cordova.plugins.Keyboard.hideKeyboardAccessoryBar(false) && cordova.plugins.Keyboard.close();
      }
      socket.removeAllListeners();
    });
    isIOS = ionic.Platform.isWebView() && ionic.Platform.isIOS();
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
        message: $scope.data.message
      });
      $scope.messages.push({
        user: 'me',
        text: $scope.data.message
      });
      $scope.data.message = "";
      window.localStorage[messageKey] = JSON.stringify($scope.messages);
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
    $scope.data = {};
  });


  /*
    w = angular.element($window)
    $scope.getHeight = ->
      w.height()
    $scope.$watch $scope.getHeight, (newValue, oldValue) ->
      $scope.windowHeight = newValue
      $scope.style = ->
        height: newValue + "px"
      return
    w.bind "resize", ->
      $scope.$apply()
      return
   */

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
    $scope.pubish = function() {
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
    $scope.yes = function() {
      return $state.go('list.createEvent');
    };
    return $scope.no = function() {
      return $state.go('list.events');
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
  angular.module("hiin").controller("grpChatCtrl", function($scope, $window, socket, Util, $location, $ionicScrollDelegate, $timeout) {
    var isIOS, messageKey, messages, myId, thisEvent;
    console.log('grpChat');
    $scope.input_mode = false;
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
    $scope.sendMessage = function() {
      socket.emit("groupMessage", {
        message: $scope.data.message
      });
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
    $scope.data = {};
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
        console.log('directive');
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
    $scope.reloadFlg = false;
    $scope.$on("$destroy", function(event) {
      socket.removeAllListeners();
    });
    socket.on("currentEvent", function(data) {
      $scope.reloadFlg = true;
      console.log("list currentEvent");
      $scope.eventName = data.name;
      window.localStorage['thisEvent'] = data.code;
      socket.emit("currentEventUserList");
      console.log("socket emit current event user list");
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
      console.log(data);
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
      $scope.sendHi = data.fromName;
      return $scope.modalInstance = $modal.open({
        templateUrl: "views/list/hi_modal.html",
        scope: $scope
      });
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
        if (attrs.histatus === '0' || attrs.histatus === '2') {
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
        if (attrs.histatus === '0' || attrs.histatus === '2') {
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
        if (attrs.histatus === '0' || attrs.histatus === '2') {
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
  angular.module('hiin').controller('MenuCtrl', function($rootScope, $scope, Util, $window, socket, $state) {
    $rootScope.selectedItem = 4;
    $scope.TermAndPolish = function() {
      $scope.slide = 'slide-left';
      return $state.go('termAndPolish');
    };
    $scope.Report = function() {
      $scope.slide = 'slide-left';
      return $state.go('report');
    };
    return $scope.signOut = function() {
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
  });

}).call(this);

(function() {
  'use strict';
  angular.module('hiin').controller('MenuEventCtrl', function($rootScope, $scope, Util, $http, socket, $log, $state, $ionicScrollDelegate, $ionicNavBarDelegate, $timeout) {
    $rootScope.selectedItem = 3;
    ionic.DomUtil.ready(function() {
      return $ionicNavBarDelegate.showBackButton(false);
    });
    if (window.localStorage['thisEvent'] != null) {
      $scope.enteredEventsOrOwner = true;
    }
    $scope.confirmCode = function() {
      return Util.ConfirmEvent($scope.formData).then(function(data) {
        return $state.go('list.userlists', null, {
          'reload': true
        });
      }, function(status) {
        return alert("invalid event code");
      });
    };
    $scope.CreateEvent = function() {
      console.log('goto Create Event');
      return $state.go('createEventAttention');
    };
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
    return $scope.GotoEvent = function(code) {
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
