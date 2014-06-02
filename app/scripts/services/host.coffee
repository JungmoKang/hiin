angular.module('services').factory 'Host', ($window, API_HOST,API_PORT) ->
  _API_HOST = API_HOST
  if $window.localStorage?
    host = $window.localStorage.getItem "api_host"
    console.log("localstorage host = #{host}")
    if host and host != ""
      _API_HOST = host
  _API_PORT = API_PORT

  getAPIHost: () ->
    return _API_HOST

  getAPIPort: () ->
    return _API_PORT

  setAPIPort: (port) ->
    console.log "set api port! host = #{port}"
    _API_PORT = port
