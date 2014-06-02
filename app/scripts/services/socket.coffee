angular.module('services').factory 'socket', (socketFactory,Host) ->
  myIoSocket = io.connect("#{Host.getAPIHost()}:#{Host.getAPIPort()}/hiin")
  mySocket = socketFactory(ioSocket: myIoSocket)
  mySocket