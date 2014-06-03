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
