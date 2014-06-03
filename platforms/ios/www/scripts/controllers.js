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
