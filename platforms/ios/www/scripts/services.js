'use strict';

// AngularJS 에서 module을 정의할 때 뒤에 dependecy list를 주게 되면 새로운 module을 정의하겠다는 소리고
// 단순히 angular.module('services') 하게 되면 기존에 만들어진 module을 refer하겠다는 의미임.

// services 라는 모듈 선언
angular.module('services', [])
  // API_PORT를 상수로 정의. API_PORT는 나중에 dependency injection에서 쓰일 수 있음.
  .constant('API_PORT', 3000)
  // API_HOST를 상수로 정의.
//  .constant('API_HOST', "http://192.168.0.26");
  .constant('API_HOST', "http://ec2-54-86-232-223.compute-1.amazonaws.com");
  //.constant('API_HOST', "http://sdent.kr");
  //.constant('API_HOST', "http://localhost");

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
        return "Female";
      } else {
        return "Male";
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
  angular.module('services').factory('socket', function(socketFactory, Host, $window) {
    var myIoSocket, mySocket;
    myIoSocket = io.connect("" + (Host.getAPIHost()) + ":" + (Host.getAPIPort()) + "/hiin", {
      query: "token=" + $window.localStorage.getItem("auth_token")
    });
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
          if (data.status < 0) {
            deferred.reject(data.status);
          }
          $window.localStorage.setItem("auth_token", data.Token);
          return deferred.resolve(data);
        }).error(function(error, status) {
          return deferred.reject(status);
        });
        return deferred.promise;
      },
      userStatus: function() {
        var deferred;
        deferred = $q.defer();
        this.authReq('get', 'userStatus', '').success(function(data) {
          console.log('-suc-userstatus');
          console.log(data);
          if (data.status < 0) {
            deferred.reject(data.status);
          }
          return deferred.resolve(data);
        }).error(function(error, status) {
          return deferred.reject(status);
        });
        return deferred.promise;
      },
      checkOrganizer: function() {
        var deferred;
        deferred = $q.defer();
        this.authReq('get', 'checkOrganizer', '').success(function(data) {
          console.log('-suc-check organizer');
          console.log(data);
          if (data.status < 0) {
            deferred.reject(data.status);
          }
          return deferred.resolve(data);
        }).error(function(error, status) {
          return deferred.reject(status);
        });
        return deferred.promise;
      },
      ConfirmEvent: function(formData) {
        var deferred;
        deferred = $q.defer();
        this.authReq('post', 'enterEvent', formData).success(function(data) {
          if (data.status < 0) {
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
