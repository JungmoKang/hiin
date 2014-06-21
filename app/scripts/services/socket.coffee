angular.module('services').factory 'socket', (socketFactory,Host,$window) ->
  myIoSocket = io.connect("#{Host.getAPIHost()}:#{Host.getAPIPort()}/hiin",
  	query: "token=" + $window.localStorage.getItem "auth_token"
  )
  mySocket = socketFactory(ioSocket: myIoSocket)
  mySocket