angular.module('services').factory 'Token', ($q, $http, $window, $location, Host) ->
  unless $window.localStorage?
    alert "$window.localStorage doesn't exist"
  authToken: () -> $window.localStorage.getItem "auth_token"
